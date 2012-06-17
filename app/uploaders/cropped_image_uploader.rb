# encoding: utf-8
class CroppedImageUploader < ImageUploader
  process :resize_to_limit => self.image_size(8)

  version :g6 do
    process :resize_to_fill => image_size(6)
    end

  version :g4 do
    process :resize_to_fill => image_size(4)
    end

  version :g3 do
    process :resize_to_fill => image_size(3)
    end

  version :g2 do
    process :resize_to_fill => image_size(2)
    end

  version :g1 do
    process :resize_to_fill => image_size(1)
    end
  
end
