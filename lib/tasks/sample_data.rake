# db:populateタスク(:dbはただの名前空間)
namespace :db do
  desc "Fill database with sample data"

  # RakeタスクがUserモデルなどのローカルのRails環境にアクセスできるようにする
  task populate: :environment do
    # User.create!は失敗したときにfalseではなく例外を発生させる

    # 最初のユーザデータ
    User.create!(name: "Example User",
                 email: "example@railstutorial.jp",
                 password: "foobar",
                 password_confirmation: "foobar",
                 admin: true)

    # 残り99人分のダミーデータ
    99.times do |n|
      name  = Faker::Name.name
      email = "example-#{n+1}@railstutorial.jp"
      password  = "password"
      User.create!(name: name,
                   email: email,
                   password: password,
                   password_confirmation: password)
    end
  end
end
