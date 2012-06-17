# encoding: utf-8
class SquareImageUploader < ImageUploader
  process :resize_to_limit => self.image_size(8,:square)

  version :g6 do
    process :resize_to_fill => image_size(6,:square)
    end

  version :g4 do
    process :resize_to_fill => image_size(4,:square)
    end

  version :g3 do
    process :resize_to_fill => image_size(3,:square)
    end

  version :g2 do
    process :resize_to_fill => image_size(2,:square)
    end

  version :g1 do
    process :resize_to_fill => image_size(1,:square)
    end
end
