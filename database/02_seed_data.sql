-- =====================================================================
--  HÔM NAY ĂN GÌ – DỮ LIỆU GỐC
--  Chạy SAU 01_schema.sql. Gồm: 60 món ăn Việt có thật (20 món mỗi miền),
--  thông báo chung và 1 tài khoản demo.
--
--  60 món được chia đều theo từng tiêu chí lọc của app:
--    • Vùng miền   : Miền bắc / Miền trung / Miền nam        -> 20 món mỗi miền
--    • Bữa ăn      : Bữa sáng / trưa / tối / Ăn nhẹ / Healthy -> 12 món mỗi loại
--    • Thời tiết   : Nắng / Mưa / Mát mẻ / Se lạnh / Lạnh     -> 12 món mỗi loại
--    • Tâm trạng   : Vui vẻ / Buồn / Bực bội / Phấn khích / Chán nản -> 12 món mỗi loại
--    • Thời gian   : ≤ 15 / 15–30 / 30–60 / > 60 phút         -> 15 món mỗi mức
--  Mỗi miền có đủ 4 món cho từng thời tiết, từng tâm trạng, từng bữa ăn.
--
--  QUÁN ĂN: không còn quán mẫu. Backend tìm quán THẬT quanh vị trí người dùng
--  (Google Places nếu có GOOGLE_PLACES_API_KEY, nếu chưa có thì OpenStreetMap).
--  Bảng restaurants vẫn giữ để bạn tự thêm quán riêng (nhớ nhập đúng toạ độ).
--
--  File này CHẠY LẠI ĐƯỢC trên database đang dùng: tài khoản, hồ sơ, bộ lọc đã lưu
--  và lịch sử chat được giữ nguyên; món đã thích / đã lưu bị xoá vì danh sách món thay đổi.
-- =====================================================================
BEGIN;

-- ------------------------------------------------------------ Dọn dữ liệu cũ
UPDATE chat_messages SET dish_ids = '{}', recipe_dish_id = NULL;   -- id món cũ không còn đúng
DELETE FROM dishes;                               -- kéo theo liked_dishes, bookmarks
DELETE FROM restaurants;                          -- bỏ 100 quán mẫu (toạ độ không chính xác)
DELETE FROM notifications WHERE user_id IS NULL;  -- thông báo chung cũ

-- ------------------------------------------------------------ Món ăn (60 món)
-- image_url: ảnh minh hoạ theo NHÓM món (phở, bún, cơm, gỏi...), chưa phải ảnh riêng từng món.
-- Muốn dùng ảnh đúng món: sửa cột image_url trong DBeaver, khoảng 1 phút sau app tự cập nhật.
INSERT INTO dishes (id, title, description, image_url, calories, prep_time_minutes, difficulty, category, likes_count, is_special_of_week, region, weather, mood, price) VALUES
(1, 'Phở bò Hà Nội', 'Bánh phở mềm trong nước dùng ninh xương bò với quế, hồi và gừng nướng, ăn cùng thịt bò tái hoặc chín và hành lá.', 'https://images.pexels.com/photos/2641886/pexels-photo-2641886.jpeg?auto=compress&cs=tinysrgb&w=1000', 450, 150, 'Khó', 'Bữa sáng', 0, TRUE, 'Miền bắc', 'Lạnh', 'Buồn', 50000),
(2, 'Bún bò Huế', 'Bún sợi to trong nước dùng xương bò nấu sả và mắm ruốc, cay nồng với bắp bò, giò heo và chả cua.', 'https://images.pexels.com/photos/1273765/pexels-photo-1273765.jpeg?auto=compress&cs=tinysrgb&w=1000', 600, 150, 'Khó', 'Bữa sáng', 0, TRUE, 'Miền trung', 'Se lạnh', 'Bực bội', 50000),
(3, 'Cơm tấm sườn bì chả', 'Cơm gạo tấm với sườn nướng mật ong, bì heo, chả trứng hấp, mỡ hành và nước mắm ngọt.', 'https://images.pexels.com/photos/1624487/pexels-photo-1624487.jpeg?auto=compress&cs=tinysrgb&w=1000', 700, 60, 'Trung bình', 'Bữa sáng', 0, TRUE, 'Miền nam', 'Se lạnh', 'Vui vẻ', 45000),
(4, 'Bún chả Hà Nội', 'Chả viên và chả miếng nướng than hoa, ăn cùng bún rối, rau sống và nước mắm pha đu đủ xanh.', 'https://images.pexels.com/photos/2410602/pexels-photo-2410602.jpeg?auto=compress&cs=tinysrgb&w=1000', 550, 45, 'Trung bình', 'Bữa trưa', 0, TRUE, 'Miền bắc', 'Se lạnh', 'Phấn khích', 50000),
(5, 'Phở cuốn', 'Bánh phở tráng mỏng cuốn thịt bò xào, xà lách và rau thơm, chấm nước mắm chua ngọt. Đặc sản phố Ngũ Xã, Hà Nội.', 'https://images.pexels.com/photos/1600711/pexels-photo-1600711.jpeg?auto=compress&cs=tinysrgb&w=1000', 320, 15, 'Dễ', 'Ăn nhẹ', 0, FALSE, 'Miền bắc', 'Nắng', 'Vui vẻ', 45000),
(6, 'Gỏi cá Nam Ô', 'Cá trích tươi thái lát trộn thính, cuốn với rau rừng và bánh tráng, chấm nước sốt đậu phộng. Đặc sản làng chài Nam Ô, Đà Nẵng.', 'https://images.pexels.com/photos/4061560/pexels-photo-4061560.jpeg?auto=compress&cs=tinysrgb&w=1000', 280, 30, 'Trung bình', 'Healthy', 0, FALSE, 'Miền trung', 'Nắng', 'Buồn', 80000),
(7, 'Bún thịt nướng', 'Bún tươi với thịt heo nướng sả, chả giò, đồ chua, rau sống và đậu phộng, chan nước mắm chua ngọt.', 'https://images.pexels.com/photos/2410602/pexels-photo-2410602.jpeg?auto=compress&cs=tinysrgb&w=1000', 550, 45, 'Trung bình', 'Bữa trưa', 0, FALSE, 'Miền nam', 'Nắng', 'Bực bội', 40000),
(8, 'Bánh tôm Hồ Tây', 'Bánh bột chiên giòn với tôm nước ngọt và khoai lang thái sợi, ăn cùng rau sống và nước chấm chua ngọt.', 'https://images.pexels.com/photos/1143754/pexels-photo-1143754.jpeg?auto=compress&cs=tinysrgb&w=1000', 380, 30, 'Trung bình', 'Ăn nhẹ', 0, FALSE, 'Miền bắc', 'Mưa', 'Buồn', 40000),
(9, 'Bánh canh cá lóc', 'Sợi bánh canh làm từ gạo, cắt tay, nấu với cá lóc đồng rim nghệ, hành lá và tiêu. Món sáng quen thuộc ở Huế và Quảng Trị.', 'https://images.pexels.com/photos/1731535/pexels-photo-1731535.jpeg?auto=compress&cs=tinysrgb&w=1000', 400, 50, 'Trung bình', 'Bữa sáng', 0, FALSE, 'Miền trung', 'Mưa', 'Bực bội', 30000),
(10, 'Hủ tiếu chay', 'Hủ tiếu trong nước dùng ninh từ củ cải, nấm và cà rốt, ăn với đậu hũ chiên và rau.', 'https://images.pexels.com/photos/1059943/pexels-photo-1059943.jpeg?auto=compress&cs=tinysrgb&w=1000', 350, 30, 'Dễ', 'Healthy', 0, FALSE, 'Miền nam', 'Mưa', 'Phấn khích', 35000),
(11, 'Nộm đu đủ bò khô', 'Đu đủ xanh bào sợi trộn bò khô, lạc rang, rau kinh giới và nước trộn chua ngọt. Món quà vặt quen thuộc quanh Hồ Gươm.', 'https://images.pexels.com/photos/4061560/pexels-photo-4061560.jpeg?auto=compress&cs=tinysrgb&w=1000', 250, 15, 'Dễ', 'Ăn nhẹ', 0, FALSE, 'Miền bắc', 'Mát mẻ', 'Bực bội', 35000),
(12, 'Gỏi mít non chay', 'Mít non luộc xé sợi trộn nấm, rau răm, đậu phộng rang và mè, xúc bằng bánh tráng nướng.', 'https://images.pexels.com/photos/4061557/pexels-photo-4061557.jpeg?auto=compress&cs=tinysrgb&w=1000', 220, 15, 'Dễ', 'Healthy', 0, FALSE, 'Miền trung', 'Mát mẻ', 'Phấn khích', 35000),
(13, 'Bánh mì thịt Sài Gòn', 'Ổ bánh mì giòn kẹp chả lụa, thịt nguội, pa tê, bơ, dưa leo, đồ chua và ngò.', 'https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg?auto=compress&cs=tinysrgb&w=1000', 450, 10, 'Dễ', 'Bữa sáng', 0, FALSE, 'Miền nam', 'Mát mẻ', 'Chán nản', 30000),
(14, 'Bánh bột lọc Huế', 'Bánh bột sắn trong veo bọc nhân tôm và thịt ba chỉ, gói lá chuối hấp, chấm nước mắm ớt.', 'https://images.pexels.com/photos/1143754/pexels-photo-1143754.jpeg?auto=compress&cs=tinysrgb&w=1000', 280, 70, 'Trung bình', 'Ăn nhẹ', 0, FALSE, 'Miền trung', 'Se lạnh', 'Chán nản', 30000),
(15, 'Lẩu mắm miền Tây', 'Nước lẩu nấu từ mắm cá linh, cá sặc, nhúng cá, tôm, mực, thịt ba chỉ, cà tím và hàng chục loại rau đồng. Giá tính cho một người.', 'https://images.pexels.com/photos/2313642/pexels-photo-2313642.jpeg?auto=compress&cs=tinysrgb&w=1000', 750, 80, 'Khó', 'Bữa tối', 0, FALSE, 'Miền nam', 'Lạnh', 'Buồn', 100000),
(16, 'Lẩu riêu cua bắp bò', 'Nồi lẩu riêu cua đồng chua thanh, nhúng bắp bò, sườn sụn, đậu phụ và rau, ăn cùng bún. Giá tính cho một người.', 'https://images.pexels.com/photos/2313642/pexels-photo-2313642.jpeg?auto=compress&cs=tinysrgb&w=1000', 700, 70, 'Trung bình', 'Bữa tối', 0, FALSE, 'Miền bắc', 'Lạnh', 'Chán nản', 90000),
(17, 'Cao lầu Hội An', 'Sợi mì vàng dai làm từ gạo ngâm nước tro, ăn với thịt xá xíu, da heo chiên, rau sống Trà Quế và rất ít nước dùng.', 'https://images.pexels.com/photos/2098085/pexels-photo-2098085.jpeg?auto=compress&cs=tinysrgb&w=1000', 500, 90, 'Khó', 'Bữa trưa', 0, FALSE, 'Miền trung', 'Lạnh', 'Vui vẻ', 45000),
(18, 'Chè ba màu', 'Ly chè ba tầng đậu đỏ, đậu xanh và thạch lá dứa, chan nước cốt dừa cùng đá bào.', 'https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg?auto=compress&cs=tinysrgb&w=1000', 300, 70, 'Dễ', 'Ăn nhẹ', 0, FALSE, 'Miền nam', 'Nắng', 'Phấn khích', 30000),
(19, 'Bún đậu mắm tôm', 'Bún lá, đậu phụ rán, chả cốm, thịt chân giò luộc và dồi, chấm mắm tôm đánh bông với quất và ớt.', 'https://images.pexels.com/photos/6260921/pexels-photo-6260921.jpeg?auto=compress&cs=tinysrgb&w=1000', 600, 15, 'Dễ', 'Bữa trưa', 0, FALSE, 'Miền bắc', 'Nắng', 'Buồn', 45000),
(20, 'Nem nướng Nha Trang', 'Nem thịt heo nướng than, cuốn bánh tráng với bánh tráng chiên giòn và rau sống, chấm nước sốt tương đậu phộng.', 'https://images.pexels.com/photos/1600711/pexels-photo-1600711.jpeg?auto=compress&cs=tinysrgb&w=1000', 500, 60, 'Trung bình', 'Bữa tối', 0, FALSE, 'Miền trung', 'Nắng', 'Bực bội', 60000),
(21, 'Bò kho bánh mì', 'Thịt bò hầm mềm với sả, quế, hồi và cà rốt, nước sốt sánh đậm, chấm cùng bánh mì nóng giòn.', 'https://images.pexels.com/photos/4109128/pexels-photo-4109128.jpeg?auto=compress&cs=tinysrgb&w=1000', 600, 120, 'Trung bình', 'Bữa sáng', 0, FALSE, 'Miền nam', 'Mưa', 'Chán nản', 50000),
(22, 'Cơm rang dưa bò', 'Cơm rang tơi, săn với dưa cải chua và thịt bò xào mềm. Món ăn đêm quen thuộc ở Hà Nội.', 'https://images.pexels.com/photos/262959/pexels-photo-262959.jpeg?auto=compress&cs=tinysrgb&w=1000', 650, 20, 'Dễ', 'Bữa tối', 0, FALSE, 'Miền bắc', 'Mưa', 'Bực bội', 50000),
(23, 'Bánh tráng nướng Đà Lạt', 'Bánh tráng nướng trên than với trứng cút, hành lá, xúc xích và tôm khô. Được gọi vui là pizza Đà Lạt.', 'https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg?auto=compress&cs=tinysrgb&w=1000', 300, 10, 'Dễ', 'Ăn nhẹ', 0, FALSE, 'Miền trung', 'Mưa', 'Phấn khích', 30000),
(24, 'Gỏi cuốn tôm thịt', 'Bánh tráng cuốn tôm luộc, thịt ba chỉ, bún và rau thơm, chấm tương đậu phộng.', 'https://images.pexels.com/photos/1600711/pexels-photo-1600711.jpeg?auto=compress&cs=tinysrgb&w=1000', 250, 15, 'Dễ', 'Ăn nhẹ', 0, FALSE, 'Miền nam', 'Mát mẻ', 'Vui vẻ', 30000),
(25, 'Chả cá Lã Vọng', 'Cá lăng ướp nghệ và riềng, nướng rồi rán trên chảo mỡ với thì là và hành, ăn với bún, lạc rang và mắm tôm.', 'https://images.pexels.com/photos/1143754/pexels-photo-1143754.jpeg?auto=compress&cs=tinysrgb&w=1000', 520, 50, 'Khó', 'Bữa tối', 0, FALSE, 'Miền bắc', 'Mát mẻ', 'Phấn khích', 120000),
(26, 'Mì Quảng', 'Sợi mì gạo bản to nhuộm nghệ với tôm, thịt heo, trứng cút và ít nước dùng đậm đà, ăn cùng bánh tráng mè và rau sống.', 'https://images.pexels.com/photos/1907244/pexels-photo-1907244.jpeg?auto=compress&cs=tinysrgb&w=1000', 520, 60, 'Trung bình', 'Bữa trưa', 0, TRUE, 'Miền trung', 'Mát mẻ', 'Chán nản', 40000),
(27, 'Bún mắm miền Tây', 'Bún với nước dùng nấu từ mắm cá linh, cá sặc, ăn cùng tôm, mực, heo quay, cà tím và rau đồng.', 'https://images.pexels.com/photos/6260921/pexels-photo-6260921.jpeg?auto=compress&cs=tinysrgb&w=1000', 600, 60, 'Khó', 'Bữa trưa', 0, FALSE, 'Miền nam', 'Se lạnh', 'Buồn', 55000),
(28, 'Mì vằn thắn', 'Mì trứng sợi nhỏ với vằn thắn nhân tôm thịt, xá xíu, gan và trứng luộc trong nước dùng ngọt thanh.', 'https://images.pexels.com/photos/1907244/pexels-photo-1907244.jpeg?auto=compress&cs=tinysrgb&w=1000', 480, 75, 'Trung bình', 'Bữa tối', 0, FALSE, 'Miền bắc', 'Se lạnh', 'Chán nản', 40000),
(29, 'Chè hạt sen Huế', 'Hạt sen hồ Tịnh Tâm nấu với đường phèn, thanh mát và bùi. Món chè cung đình xứ Huế.', 'https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg?auto=compress&cs=tinysrgb&w=1000', 200, 70, 'Dễ', 'Healthy', 0, FALSE, 'Miền trung', 'Se lạnh', 'Vui vẻ', 30000),
(30, 'Hủ tiếu Nam Vang', 'Sợi hủ tiếu dai trong nước dùng xương heo, ăn với tôm, thịt băm, gan, trứng cút và hẹ.', 'https://images.pexels.com/photos/1273765/pexels-photo-1273765.jpeg?auto=compress&cs=tinysrgb&w=1000', 480, 100, 'Trung bình', 'Bữa sáng', 0, FALSE, 'Miền nam', 'Lạnh', 'Bực bội', 45000),
(31, 'Nem rán Hà Nội', 'Nem cuốn bánh đa nem với thịt lợn băm, miến, mộc nhĩ và trứng, rán vàng giòn, chấm nước mắm pha tỏi ớt.', 'https://images.pexels.com/photos/1143754/pexels-photo-1143754.jpeg?auto=compress&cs=tinysrgb&w=1000', 400, 45, 'Trung bình', 'Ăn nhẹ', 0, FALSE, 'Miền bắc', 'Lạnh', 'Vui vẻ', 45000),
(32, 'Bún chả cá Đà Nẵng', 'Bún với chả cá thu chiên và hấp, nước dùng ngọt từ xương cá, bí đỏ, thơm và cà chua.', 'https://images.pexels.com/photos/6260921/pexels-photo-6260921.jpeg?auto=compress&cs=tinysrgb&w=1000', 450, 80, 'Trung bình', 'Bữa sáng', 0, FALSE, 'Miền trung', 'Lạnh', 'Buồn', 35000),
(33, 'Lẩu cá kèo lá giang', 'Cá kèo còn sống thả vào nồi nước lẩu chua thanh nấu lá giang, ăn với bún và rau đắng. Giá tính cho một người.', 'https://images.pexels.com/photos/2313642/pexels-photo-2313642.jpeg?auto=compress&cs=tinysrgb&w=1000', 500, 30, 'Trung bình', 'Bữa tối', 0, FALSE, 'Miền nam', 'Nắng', 'Chán nản', 90000),
(34, 'Nộm hoa chuối', 'Hoa chuối thái mỏng trộn lạc rang, vừng, rau thơm và nước trộn chua ngọt. Món chay thanh mát, ăn sần sật.', 'https://images.pexels.com/photos/4061557/pexels-photo-4061557.jpeg?auto=compress&cs=tinysrgb&w=1000', 180, 15, 'Dễ', 'Healthy', 0, FALSE, 'Miền bắc', 'Nắng', 'Bực bội', 30000),
(35, 'Bánh mì Hội An', 'Bánh mì vỏ giòn kẹp pa tê, thịt nướng, chả, rau thơm và nước sốt riêng có ở phố cổ Hội An.', 'https://images.pexels.com/photos/4109130/pexels-photo-4109130.jpeg?auto=compress&cs=tinysrgb&w=1000', 480, 15, 'Dễ', 'Bữa sáng', 0, FALSE, 'Miền trung', 'Nắng', 'Phấn khích', 30000),
(36, 'Cơm gà xối mỡ', 'Đùi gà chiên bằng cách xối mỡ nóng cho da giòn rụm, ăn với cơm chiên vàng và dưa chua.', 'https://images.pexels.com/photos/2116094/pexels-photo-2116094.jpeg?auto=compress&cs=tinysrgb&w=1000', 750, 50, 'Trung bình', 'Bữa trưa', 0, FALSE, 'Miền nam', 'Mưa', 'Vui vẻ', 45000),
(37, 'Bún riêu cua', 'Bún với riêu cua đồng, cà chua, đậu phụ rán và mắm tôm, nước dùng chua thanh từ dấm bỗng.', 'https://images.pexels.com/photos/1273765/pexels-photo-1273765.jpeg?auto=compress&cs=tinysrgb&w=1000', 420, 60, 'Trung bình', 'Bữa trưa', 0, FALSE, 'Miền bắc', 'Mưa', 'Phấn khích', 35000),
(38, 'Cơm hến Huế', 'Cơm nguội trộn hến xào (loài sò nhỏ ở sông Hương), tóp mỡ heo, đậu phộng, rau thơm và mắm ruốc, ăn cùng bát nước hến nóng.', 'https://images.pexels.com/photos/2116094/pexels-photo-2116094.jpeg?auto=compress&cs=tinysrgb&w=1000', 400, 45, 'Trung bình', 'Bữa trưa', 0, FALSE, 'Miền trung', 'Mưa', 'Chán nản', 30000),
(39, 'Gỏi cuốn chay', 'Bánh tráng cuốn đậu hũ, nấm, bún và rau thơm, chấm tương đậu phộng.', 'https://images.pexels.com/photos/1600711/pexels-photo-1600711.jpeg?auto=compress&cs=tinysrgb&w=1000', 200, 15, 'Dễ', 'Healthy', 0, FALSE, 'Miền nam', 'Mát mẻ', 'Buồn', 30000),
(40, 'Canh cua rau đay', 'Canh cua đồng nấu rau đay, mồng tơi và mướp, ăn cùng cà pháo muối. Vị ngọt mát của mùa hè miền Bắc.', 'https://images.pexels.com/photos/1640772/pexels-photo-1640772.jpeg?auto=compress&cs=tinysrgb&w=1000', 150, 30, 'Trung bình', 'Healthy', 0, FALSE, 'Miền bắc', 'Mát mẻ', 'Chán nản', 35000),
(41, 'Phở khô Gia Lai', 'Còn gọi là phở hai tô: một tô bánh phở khô trộn thịt băm và hành phi, một tô nước dùng bò viên riêng.', 'https://images.pexels.com/photos/2641886/pexels-photo-2641886.jpeg?auto=compress&cs=tinysrgb&w=1000', 480, 15, 'Dễ', 'Bữa tối', 0, FALSE, 'Miền trung', 'Mát mẻ', 'Vui vẻ', 40000),
(42, 'Bánh tráng trộn', 'Bánh tráng cắt sợi trộn xoài xanh, tôm khô, khô bò, trứng cút, rau răm và sa tế. Quà vặt đường phố Sài Gòn.', 'https://images.pexels.com/photos/4061557/pexels-photo-4061557.jpeg?auto=compress&cs=tinysrgb&w=1000', 330, 10, 'Dễ', 'Ăn nhẹ', 0, FALSE, 'Miền nam', 'Se lạnh', 'Bực bội', 30000),
(43, 'Đậu phụ sốt cà chua', 'Đậu phụ rán vàng om với sốt cà chua và hành lá. Món chay đậm đà, đưa miệng.', 'https://images.pexels.com/photos/1059943/pexels-photo-1059943.jpeg?auto=compress&cs=tinysrgb&w=1000', 220, 20, 'Dễ', 'Healthy', 0, FALSE, 'Miền bắc', 'Se lạnh', 'Vui vẻ', 30000),
(44, 'Cơm gà Hội An', 'Cơm nấu nước luộc gà và nghệ, gà ta xé trộn hành tây, rau răm, ăn với đu đủ bào chua ngọt.', 'https://images.pexels.com/photos/2116094/pexels-photo-2116094.jpeg?auto=compress&cs=tinysrgb&w=1000', 600, 60, 'Trung bình', 'Bữa trưa', 0, FALSE, 'Miền trung', 'Se lạnh', 'Buồn', 45000),
(45, 'Bột chiên Sài Gòn', 'Bột gạo cắt khối chiên giòn với trứng và hành lá, ăn cùng đu đủ bào và nước tương pha.', 'https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg?auto=compress&cs=tinysrgb&w=1000', 500, 15, 'Dễ', 'Ăn nhẹ', 0, FALSE, 'Miền nam', 'Lạnh', 'Phấn khích', 30000),
(46, 'Bánh cuốn Thanh Trì', 'Bánh cuốn tráng mỏng từ gạo xay, rắc hành phi, ăn với chả quế và nước mắm pha nhạt.', 'https://images.pexels.com/photos/1143754/pexels-photo-1143754.jpeg?auto=compress&cs=tinysrgb&w=1000', 300, 30, 'Trung bình', 'Bữa sáng', 0, FALSE, 'Miền bắc', 'Nắng', 'Phấn khích', 30000),
(47, 'Cơm chay Huế', 'Mâm cơm chay kiểu Huế với đậu hũ, nấm kho, rau củ luộc và canh rau, nấu thanh đạm theo lối nhà chùa.', 'https://images.pexels.com/photos/1059943/pexels-photo-1059943.jpeg?auto=compress&cs=tinysrgb&w=1000', 450, 30, 'Trung bình', 'Healthy', 0, FALSE, 'Miền trung', 'Lạnh', 'Bực bội', 45000),
(48, 'Gỏi ngó sen tôm thịt', 'Ngó sen trắng trộn tôm, thịt ba chỉ, cà rốt và rau răm với nước mắm chua ngọt, ăn cùng bánh phồng tôm.', 'https://images.pexels.com/photos/4061560/pexels-photo-4061560.jpeg?auto=compress&cs=tinysrgb&w=1000', 280, 25, 'Dễ', 'Healthy', 0, FALSE, 'Miền nam', 'Nắng', 'Vui vẻ', 60000),
(49, 'Rau muống xào tỏi', 'Rau muống xanh mướt xào lửa lớn với tỏi đập dập. Món rau quen thuộc nhất trên mâm ăn người Việt.', 'https://images.pexels.com/photos/1059943/pexels-photo-1059943.jpeg?auto=compress&cs=tinysrgb&w=1000', 120, 10, 'Dễ', 'Healthy', 0, FALSE, 'Miền bắc', 'Mưa', 'Chán nản', 30000),
(50, 'Bánh bèo Huế', 'Bánh gạo hấp trong chén nhỏ, rắc tôm chấy và tóp mỡ, chan nước mắm ngọt.', 'https://images.pexels.com/photos/1143754/pexels-photo-1143754.jpeg?auto=compress&cs=tinysrgb&w=1000', 300, 30, 'Trung bình', 'Ăn nhẹ', 0, FALSE, 'Miền trung', 'Nắng', 'Chán nản', 30000),
(51, 'Bánh xèo miền Tây', 'Bánh xèo vàng giòn to bằng cái chảo, nhân tôm, thịt ba chỉ, giá và đậu xanh, cuốn cải xanh chấm nước mắm chua ngọt.', 'https://images.pexels.com/photos/1143754/pexels-photo-1143754.jpeg?auto=compress&cs=tinysrgb&w=1000', 550, 30, 'Trung bình', 'Bữa tối', 0, FALSE, 'Miền nam', 'Mưa', 'Buồn', 50000),
(52, 'Bún thang', 'Bún với trứng tráng thái chỉ, giò lụa, thịt gà xé, tôm khô và nấm hương trong nước dùng gà trong vắt. Món cầu kỳ bậc nhất Hà Nội.', 'https://images.pexels.com/photos/1273765/pexels-photo-1273765.jpeg?auto=compress&cs=tinysrgb&w=1000', 400, 90, 'Khó', 'Bữa sáng', 0, FALSE, 'Miền bắc', 'Mát mẻ', 'Vui vẻ', 45000),
(53, 'Bánh xèo tôm nhảy Bình Định', 'Bánh xèo nhỏ đổ từ gạo xay với tôm đất tươi và giá, cuốn bánh tráng cùng rau sống, chấm nước mắm tỏi ớt.', 'https://images.pexels.com/photos/1143754/pexels-photo-1143754.jpeg?auto=compress&cs=tinysrgb&w=1000', 450, 30, 'Trung bình', 'Bữa tối', 0, FALSE, 'Miền trung', 'Mưa', 'Vui vẻ', 40000),
(54, 'Canh chua cá lóc', 'Canh cá lóc nấu chua với thơm, cà chua, bạc hà và giá, dậy mùi ngò gai, rau om.', 'https://images.pexels.com/photos/1731535/pexels-photo-1731535.jpeg?auto=compress&cs=tinysrgb&w=1000', 250, 30, 'Dễ', 'Bữa trưa', 0, FALSE, 'Miền nam', 'Mát mẻ', 'Bực bội', 60000),
(55, 'Xôi xéo', 'Xôi nếp nhuộm nghệ vàng, phủ đậu xanh đồ chín thái lát và hành phi thơm, gói trong lá sen.', 'https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg?auto=compress&cs=tinysrgb&w=1000', 450, 60, 'Trung bình', 'Bữa sáng', 0, FALSE, 'Miền bắc', 'Se lạnh', 'Buồn', 30000),
(56, 'Bánh căn Phan Rang', 'Bánh gạo xay đổ khuôn đất nung với trứng hoặc tôm mực, chấm mắm nêm, nước cá kho và xíu mại.', 'https://images.pexels.com/photos/1143754/pexels-photo-1143754.jpeg?auto=compress&cs=tinysrgb&w=1000', 350, 15, 'Trung bình', 'Ăn nhẹ', 0, FALSE, 'Miền trung', 'Mát mẻ', 'Buồn', 30000),
(57, 'Mì vịt tiềm', 'Mì trứng với đùi vịt chiên rồi hầm thuốc bắc và nấm đông cô cho mềm rục, nước dùng đậm, ăn cùng cải xanh.', 'https://images.pexels.com/photos/2098085/pexels-photo-2098085.jpeg?auto=compress&cs=tinysrgb&w=1000', 650, 150, 'Khó', 'Bữa tối', 0, FALSE, 'Miền nam', 'Se lạnh', 'Phấn khích', 70000),
(58, 'Phở gà', 'Bánh phở trong nước dùng gà ta trong và ngọt, thịt gà xé, lá chanh thái chỉ và hành lá.', 'https://images.pexels.com/photos/2641886/pexels-photo-2641886.jpeg?auto=compress&cs=tinysrgb&w=1000', 400, 90, 'Trung bình', 'Bữa trưa', 0, FALSE, 'Miền bắc', 'Lạnh', 'Bực bội', 45000),
(59, 'Lẩu thả Phan Thiết', 'Cá mai tái chanh, thịt luộc, trứng tráng và rau bày như bông hoa rồi thả vào nước lẩu ngọt thanh. Đặc sản làng chài Mũi Né, giá tính cho một người.', 'https://images.pexels.com/photos/2313642/pexels-photo-2313642.jpeg?auto=compress&cs=tinysrgb&w=1000', 550, 30, 'Trung bình', 'Bữa tối', 0, FALSE, 'Miền trung', 'Lạnh', 'Phấn khích', 100000),
(60, 'Canh khổ qua nhồi thịt', 'Khổ qua nhồi thịt heo băm và mộc nhĩ, hầm trong nước dùng trong. Vị đắng nhẹ, hậu ngọt.', 'https://images.pexels.com/photos/1640772/pexels-photo-1640772.jpeg?auto=compress&cs=tinysrgb&w=1000', 200, 50, 'Dễ', 'Healthy', 0, FALSE, 'Miền nam', 'Lạnh', 'Chán nản', 40000);

SELECT setval('dishes_id_seq', (SELECT MAX(id) FROM dishes));

-- ------------------------------------------------------------ Quán ăn
-- (để trống) Quán được lấy trực tiếp từ Google Places / OpenStreetMap theo vị trí người dùng.
-- Tự thêm quán riêng, ví dụ:
-- INSERT INTO restaurants (name, address, rating, image_url, category, latitude, longitude, open_minute, close_minute)
-- VALUES ('Tên quán', 'Địa chỉ', 4.5, '', 'Nhà hàng', 21.0, 105.8, 360, 1320);

-- ------------------------------------------------------------ Thông báo (gửi cho tất cả)
INSERT INTO notifications (title, message, type, icon, image_url, created_at) VALUES
('Chào mừng bạn đến với Hôm Nay Ăn Gì!', 'Kể cho app nghe thời tiết, tâm trạng và ngân sách, bạn sẽ nhận được gợi ý món ăn phù hợp cùng quán gần mình.', 'update', 'celebration', NULL, NOW() - INTERVAL '4 days'),
('Thực đơn mới: 60 món Việt ba miền', 'Danh sách món đã được làm mới với 60 món có thật của miền Bắc, miền Trung và miền Nam, chia đều theo bữa ăn, thời tiết và tâm trạng.', 'update', 'restaurant', NULL, NOW() - INTERVAL '1 day'),
('Tìm quán thật quanh bạn', 'Bật định vị để mục Quán ăn hiển thị các quán có thật gần vị trí của bạn, kèm khoảng cách và nút chỉ đường Google Maps.', 'update', 'auto_awesome', NULL, NOW() - INTERVAL '5 hours'),
('Muốn ăn nhẹ nhàng?', 'Chọn nhóm Healthy khi tìm kiếm để xem 12 món thanh đạm như nộm hoa chuối, gỏi cuốn chay, canh khổ qua nhồi thịt.', 'personal', 'fitness_center', NULL, NOW() - INTERVAL '2 hours'),
('Trời lạnh ăn gì?', 'Mở Bộ lọc, chọn thời tiết "Lạnh" để xem lẩu riêu cua bắp bò, phở gà, lẩu mắm miền Tây và nhiều món nóng khác.', 'personal', 'auto_awesome', NULL, NOW() - INTERVAL '15 minutes');

-- ------------------------------------------------------------ Tài khoản demo
INSERT INTO users (email, display_name, bio, avatar_url, is_demo)
SELECT 'demo@homnayangi.vn', 'Nguyễn Tuấn', 'Người đam mê công nghệ và ẩm thực đường phố.',
       'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=800&auto=format&fit=crop', TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE is_demo);
INSERT INTO user_preferences (user_id, height, weight, gender, birth_year, activity_level)
SELECT id, 170, 65, 'Nam', 2002, 'Vận động nhẹ' FROM users WHERE is_demo
ON CONFLICT (user_id) DO NOTHING;
-- Tài khoản demo thích sẵn Phở bò Hà Nội (1) và Bún chả Hà Nội (4)
INSERT INTO liked_dishes (user_id, dish_id) SELECT id, 1 FROM users WHERE is_demo ON CONFLICT DO NOTHING;
INSERT INTO liked_dishes (user_id, dish_id) SELECT id, 4 FROM users WHERE is_demo ON CONFLICT DO NOTHING;

-- Lượt thích = số người dùng thật sự đã thích (không dùng số giả)
UPDATE dishes SET likes_count = (SELECT COUNT(*) FROM liked_dishes l WHERE l.dish_id = dishes.id);

COMMIT;

-- Kiểm tra nhanh
SELECT 'dishes' AS bang, COUNT(*) FROM dishes
UNION ALL SELECT 'restaurants', COUNT(*) FROM restaurants
UNION ALL SELECT 'notifications', COUNT(*) FROM notifications
UNION ALL SELECT 'users', COUNT(*) FROM users;
