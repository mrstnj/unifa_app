class UserImage < ApplicationRecord
  has_one_attached :image
  belongs_to :user

  validates :title, presence: { message: "タイトルを入力してください" }, length: { maximum: 30, message: "タイトルは30文字以内で入力してください" }
  validates :image, presence: { message: "画像ファイルを入力してください" }
end
