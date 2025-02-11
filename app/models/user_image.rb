class UserImage < ApplicationRecord
  has_one_attached :image
  belongs_to :user

  validates :title, presence: { message: "タイトルを入力してください" }, length: { maximum: 30, message: "タイトルは30文字以内で入力してください" }
  validates :image, presence: { message: "画像ファイルを入力してください" }
  validate :acceptable_image

  private

  def acceptable_image
    return unless image.attached?

    unless image.byte_size <= 5.megabyte
      errors.add(:image, message: '画像ファイルのサイズは5MB以下にしてください')
    end

    acceptable_types = ['image/jpeg', 'image/jpg', 'image/png']
    unless acceptable_types.include?(image.content_type)
      errors.add(:image, message: '画像ファイルはJPG、JPEG、PNG形式のみ対応しています')
    end
  end
end
