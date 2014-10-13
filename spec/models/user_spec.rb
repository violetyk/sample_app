require 'rails_helper'

RSpec.describe User, :type => :model do
  # pending "add some examples to (or delete) #{__FILE__}"

  before { @user = User.new(name: "Example User", email: 'user@example.com', password: 'foobar', password_confirmation: 'foobar') }

  # @user をテストサンプルのデフォルトとのsubjectとして設定する
  subject { @user }

  # name属性とemail属性の存在をテスト
  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  # データベースには保存されない、モデルのみの仮装属性
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }


  it { should respond_to(:remember_token) }

  # @user.valid? の結果をテストしているのと同じ。subject { @user }があるので@userを使う必要が無い。
  it { should be_valid }

  # has_secure_passwordを使って認証機能が付いているかどうか
  it { should respond_to(:authenticate) }

  # adminのテスト
  it { should respond_to(:admin) }

  it { should be_valid }
  it { should_not be_admin }
  describe "with admin attribute set to 'true'" do
    before do
      @user.save!
      @user.toggle!(:admin)
    end

    it { should be_admin }
  end

  describe "when name is not present" do
    before { @user.name = " " }
    # @userのデータが正しくないこと
    it { should_not be_valid }
  end

  describe "when email is not present" do
    before { @user.email = " " }
    it { should_not be_valid }
  end

  describe "when name is too long" do
    before { @user.name = "a" * 51 }
    it { should_not be_valid }
  end


  describe "when email format is invalid" do
    it "should be invalid" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo. foo@bar_baz.com foo@bar+baz.com]
      addresses.each do |invalid_address|
        @user.email = invalid_address
        expect(@user).not_to be_valid
      end
    end
  end

  describe "when email format is valid" do
    it "should be valid" do
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        @user.email = valid_address
        expect(@user).to be_valid
      end
    end
  end

  # メールアドレスの重複チェックをしていること
  describe "when email address is already taken" do
    before do
      user_with_same_email = @user.dup
      user_with_same_email.email = @user.email.upcase
      user_with_same_email.save
    end

    it { should_not be_valid }
  end

  # パスワードが空欄でないこと
  describe "when password is not present" do
    before do
      # @user = User.new(name: "Example User", email: "user@example.com", password: " ", password_confirmation: " ")
      @user = User.new(name: "Example User", email: "user@example.com", password: "", password_confirmation: "")
    end
    subject { @user }
    it { should_not be_valid }
  end

  # パスワード不一致のテスト
  describe "when password doesn't match confirmation" do
    before { @user.password_confirmation = "mismatch" }
    it { should_not be_valid }
  end


  # 認証のテスト
  describe "return value of authenticate method" do
    # 事前にユーザをデータベースに保存
    before { @user.save }

    # letではfound_userという変数を作って値をセットしている
    let(:found_user) { User.find_by(email: @user.email) }

    # 正しいパスワードの場合
    describe "with valid password" do
      it { should eq found_user.authenticate(@user.password) }
    end

    # パスワードが間違っている場合
    describe "with invalid password" do
      let(:user_for_invalid_password) { found_user.authenticate("invalid") }

      it { should_not eq user_for_invalid_password }
      # specify { expect(user_for_invalid_password).to be_false }
      specify { expect(user_for_invalid_password).to be_falsey }
      specify { expect(user_for_invalid_password).to be false }
      # specify { user_for_invalid_password should be_falsey }
    end
  end

  # パスワードの長さのテスト
  describe "with a password that's too short" do
    before { @user.password = @user.password_confirmation = "a" * 5 }
    it { should be_invalid }
  end


  # emember_tokenをコールバックで保存することを確認するテスト
  describe "remember token" do
    before { @user.save }
    its(:remember_token) { should_not be_blank }
  end
end
