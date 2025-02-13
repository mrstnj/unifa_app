class UserImage < ApplicationRecord
  has_one_attached :image
  belongs_to :user

  validates :title, presence: { message: "タイトルを入力してください" }, length: { maximum: 30, message: "タイトルは30文字以内で入力してください" }
  validates :image, presence: { message: "画像ファイルを入力してください" }
  validate :acceptable_image

  before_save :set_filename, if: -> { image.attached? }

  def thumbnail
    image.variant(resize_to_fit: [300, 200]).processed
  end

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

  def set_filename
    return unless image.attached?

    ext = File.extname(image.filename.to_s).downcase
    filename = SecureRandom.uuid
    image.blob.filename = "#{filename}#{ext}"
  end
end
