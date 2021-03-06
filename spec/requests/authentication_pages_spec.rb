require 'rails_helper'

# RSpec.describe "AuthenticationPages", :type => :request do
  # describe "GET /authentication_pages" do
    # it "works! (now write some real specs)" do
      # get authentication_pages_index_path
      # expect(response).to have_http_status(200)
    # end
  # end
# end


require 'spec_helper'
require 'support/utilities.rb'

describe "Authentication" do

  subject { page }

  describe "signin page" do
    before { visit signin_path }

    # ログイン失敗のテスト
    describe "with invalid information" do
      before { click_button "Sign in" }

      it { should have_title('Sign in') }
      it { should have_selector('div.alert.alert-error', text: 'Invalid') }

      describe "after visiting another page" do
        before { click_link "Home" }
        it { should_not have_selector('div.alert.alert-error') }
      end
    end

    # ログイン成功のテスト
    describe "with valid information" do
      let(:user) { FactoryGirl.create(:user) }
      # before do
        # fill_in "Email",    with: user.email.upcase
        # fill_in "Password", with: user.password
        # click_button "Sign in"
      # end
      before { sign_in user }

      it { should have_title(user.name) }
      it { should have_link('Users',       href: users_path) }
      it { should have_link('Profile',     href: user_path(user)) }
      it { should have_link('Settings',    href: edit_user_path(user)) }
      it { should have_link('Sign out',    href: signout_path) }
      it { should_not have_link('Sign in', href: signin_path) }

      # ログアウトのテスト
      describe "followed by signout" do
        before { click_link "Sign out" }
        it { should have_link('Sign in') }
      end
    end

  end


  describe "authorization" do

    # ログインしていないユーザの場合のテスト
    describe "for non-signed-in users" do
      let(:user) { FactoryGirl.create(:user) }

      describe "in the Users controller" do

        describe "visiting the edit page" do
          before { visit edit_user_path(user) }
          it { should have_title('Sign in') }
        end

        # ログインしていなかったらログイン画面へ遷移すること
        describe "submitting to the update action" do
          # /users/1にPATCHリクエストを送る
          before { patch user_path(user) }
          specify { expect(response).to redirect_to(signin_path) }
        end


        # index はログインが必要
        describe "visiting the user index" do
          before { visit users_path }
          it { should have_title('Sign in') }
        end

        # フォローしているユーザを表示するページはログインが必要
        describe "visiting the following page" do
          before { visit following_user_path(user) }
          it { should have_title('Sign in') }
        end

        # フォロワーを表示するページはログインが必要
        describe "visiting the followers page" do
          before { visit followers_user_path(user) }
          it { should have_title('Sign in') }
        end

      end


      # Relationshipコントローラのpostとdeleteはログインが必要
      describe "in the Relationships controller" do
        describe "submitting to the create action" do
          before { post relationships_path }
          specify { expect(response).to redirect_to(signin_path) }
        end

        describe "submitting to the destroy action" do
          before { delete relationship_path(1) }
          specify { expect(response).to redirect_to(signin_path) }
        end
      end



      # フレンドリーフォワーディング機能のテスト
      # ログイン前にみようとしてページへログイン後に遷移すること
      describe "when attempting to visit a protected page" do
        before do
          visit edit_user_path(user)
          fill_in "Email",    with: user.email
          fill_in "Password", with: user.password
          click_button "Sign in"
        end

        describe "after signing in" do

          it "should render the desired protected page" do
            expect(page).to have_title('Edit user')
          end
        end
      end

      describe "in the Microposts controller" do

        # ログインしていない場合にはマイクロポストがポストできないこと
        describe "submitting to the create action" do
          before { post microposts_path }
          specify { expect(response).to redirect_to(signin_path) }
        end

        # ログインしていない場合にはマイクロポストが削除できないこと
        describe "submitting to the destroy action" do
          before { delete micropost_path(FactoryGirl.create(:micropost)) }
          specify { expect(response).to redirect_to(signin_path) }
        end
      end

    end


    # 自分以外は更新できないテスト
    describe "as wrong user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:wrong_user) { FactoryGirl.create(:user, email: "wrong@example.com") }
      before { sign_in user, no_capybara: true }

      describe "submitting a GET request to the Users#edit action" do
        before { get edit_user_path(wrong_user) }
        specify { expect(response.body).not_to match(full_title('Edit user')) }
        specify { expect(response).to redirect_to(root_url) }
      end

      describe "submitting a PATCH request to the Users#update action" do
        before { patch user_path(wrong_user) }
        specify { expect(response).to redirect_to(root_path) }
      end
    end


    # adminではないユーザがDELETEリクエストを直接実行しても大丈夫なこと
    describe "as non-admin user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:non_admin) { FactoryGirl.create(:user) }

      before { sign_in non_admin, no_capybara: true }

      describe "submitting a DELETE request to the Users#destroy action" do
        before { delete user_path(user) }
        specify { expect(response).to redirect_to(root_path) }
      end
    end

  end
end
