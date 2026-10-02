# Hôm Nay Ăn Gì – Flutter + Spring Boot + PostgreSQL

Ứng dụng gợi ý món ăn theo tâm trạng, thời tiết, ngân sách và tìm quán ăn thật quanh vị trí của bạn.
Dự án được tách thành 3 phần:

```
HomNayAnGi/
├── database/   Script SQL cho PostgreSQL (Docker tự nạp lần đầu)
├── docker-compose.yml  Chạy PostgreSQL bằng Docker
├── backend/    API Spring Boot (Java 17) – toàn bộ logic + kết nối database
└── frontend/   App Flutter (Android / iOS / Web) – giao diện, gọi API của backend
```

```
App Flutter ──HTTP/JSON──► Spring Boot (cổng 8080) ──JDBC──► PostgreSQL (cổng 5432)
                                 ├──► Gemini API (chatbot)
                                 └──► Google Places API (tìm quán thật quanh bạn, cần key)
                                      hoặc OpenStreetMap (miễn phí, tự dùng khi chưa có key)
```

---

## File cấu hình không có trên GitHub

Các file chứa key được giữ ngoài repo. Sau khi tải code về, tạo lại chúng trước khi chạy:

| File | Cách tạo |
|---|---|
| `backend/.env` | Copy `backend/.env.example`, điền `GEMINI_API_KEY` (và `GOOGLE_PLACES_API_KEY` nếu có) |
| `frontend/.env` | Copy `frontend/.env.example` (bắt buộc phải có file này thì app mới build được) |
| `frontend/android/app/google-services.json` | Tải từ Firebase Console > Project settings > Your apps > Android |
| `backend/oauth2.json` | Tuỳ chọn: service account của Firebase, xem mục *Đăng nhập Google* |

## Bước 1 – Cài đặt cần có

| Phần mềm | Ghi chú |
|---|---|
| **Docker Desktop** | Chạy PostgreSQL trong container, không cần cài PostgreSQL |
| **DBeaver** | Xem / sửa dữ liệu |
| **IntelliJ IDEA** (hoặc Android Studio) | Chạy backend Spring Boot. Cần JDK 17 trở lên |
| **Flutter SDK** + plugin Flutter cho IDE | Chạy app |

## Bước 2 – Chạy database bằng Docker

1. Mở **Docker Desktop**, chờ góc dưới bên trái báo *Engine running*.
2. Mở PowerShell tại thư mục gốc `HomNayAnGi` (nơi có file `docker-compose.yml`) và chạy:
   ```powershell
   docker compose up -d
   ```
   Lần đầu Docker tải image `postgres:16` rồi **tự chạy** `database/01_schema.sql` và `02_seed_data.sql`.
3. Kiểm tra: `docker compose ps` thấy `homnayangi-db` ở trạng thái `running (healthy)` là xong.

### Kết nối DBeaver vào PostgreSQL trong Docker

DBeaver → **New Database Connection → PostgreSQL**:

| Ô | Giá trị |
|---|---|
| Host | `localhost` |
| Port | `5432` |
| Database | `homnayangi` |
| Username | `postgres` |
| Password | `postgres` (tích *Save password*) |

**Test Connection** (cho phép tải driver) → Finish. Mở `homnayangi → Schemas → public → Tables` sẽ thấy 12 bảng.

### Lệnh Docker hay dùng

| Việc | Lệnh |
|---|---|
| Bật database | `docker compose up -d` |
| Tắt database (giữ dữ liệu) | `docker compose stop` |
| Xem log | `docker compose logs -f db` |
| **Xoá sạch, nạp lại dữ liệu gốc** | `docker compose down -v` rồi `docker compose up -d` |

Dữ liệu nằm trong volume Docker `homnayangi-data`, tắt máy không mất. Container đặt `restart: unless-stopped`
nên mở Docker Desktop là database tự bật lại.

> Chỉ sửa file SQL thì Docker **không** tự chạy lại. Muốn áp dụng phải `docker compose down -v` rồi `up -d`
> (sẽ xoá dữ liệu đã thêm), hoặc chạy script thủ công trong DBeaver.

## Bước 3 – Chạy backend (Spring Boot)

1. Tạo file `backend/.env` (nếu chưa có) bằng cách copy `backend/.env.example`.
   Dùng Docker thì **giữ nguyên** thông số DB (`postgres` / `postgres`), chỉ cần điền `GEMINI_API_KEY`.
2. Trong Android Studio mở tab **Terminal** (Alt + F12), chạy:

   **Windows (PowerShell):**
   ```powershell
   cd backend
   $env:JAVA_HOME="C:\Program Files\Android\Android Studio\jbr"
   .\mvnw.cmd spring-boot:run
   ```
   **macOS:**
   ```bash
   cd backend
   export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
   ./mvnw spring-boot:run
   ```
   Lần đầu sẽ tải Maven và thư viện (vài phút, cần mạng). Thấy dòng `Started HomNayAnGiApplication` là xong.
   Nếu đã cài JDK 17+ riêng thì không cần dòng `JAVA_HOME`.
3. Kiểm tra trên trình duyệt:
   - http://localhost:8080/api/health → `{"status":"UP","database":true,"dishes":60,...}`
   - http://localhost:8080/swagger-ui.html → trang thử tất cả API
     (gọi `POST /api/auth/guest` lấy `token`, bấm **Authorize** dán token để thử các API cần đăng nhập).

> **Cách dễ hơn – IntelliJ:** File → Open → chọn thư mục `backend` → Trust Project, chờ tải Maven xong.
> File → Project Structure → SDK chọn JDK 17/21 (chưa có thì *Download JDK*). Mở
> `src/main/java/vn/homnayangi/api/HomNayAnGiApplication.java` → bấm ▶ cạnh `main` → Run.
> Nếu báo sai mật khẩu DB: Run → Edit Configurations → Working directory = thư mục `backend`.

Chạy test logic backend: `.\mvnw.cmd test`

## Bước 4 – Chạy app Flutter

1. Android Studio → **Open** thư mục `frontend`.
2. Terminal: `flutter pub get`
3. Chọn thiết bị và nhấn **Run**:
   - **Máy ảo Android**: không cần cấu hình, app tự gọi `http://10.0.2.2:8080` (= localhost của máy tính).
   - **Chrome (Web)**: tự gọi `http://localhost:8080`.
   - **Điện thoại thật** (cùng Wi-Fi với máy tính): mở `frontend/.env`, điền IP LAN của máy tính
     (xem bằng `ipconfig`, dòng IPv4), ví dụ `API_BASE_URL=http://192.168.1.10:8080`.
     Nếu không kết nối được, cho phép Java qua Windows Firewall (mạng Private).
   - Hoặc truyền khi chạy: `flutter run --dart-define=API_URL=http://192.168.1.10:8080`
4. Màn đăng nhập: chọn **Bỏ qua** để dùng tài khoản khách (dữ liệu vẫn lưu trên server),
   hoặc **Đăng nhập Google** (xem mục Firebase bên dưới).

Mở DBeaver xem các bảng `users`, `liked_dishes`, `bookmarks`, `saved_filters`, `chat_messages`...
sẽ thấy dữ liệu thay đổi ngay khi thao tác trên app. Sửa món trong bảng `dishes` bằng DBeaver thì
khoảng 1 phút sau app sẽ thấy (backend tự nạp lại).

---

## Dữ liệu món ăn và quán ăn

### 60 món ăn thật

`database/02_seed_data.sql` chứa 60 món Việt có thật, chia đều theo mọi tiêu chí lọc của app:

| Tiêu chí | Phân bố |
|---|---|
| Vùng miền | 20 món mỗi miền (Bắc, Trung, Nam) |
| Bữa ăn | 12 món mỗi loại (Bữa sáng, Bữa trưa, Bữa tối, Ăn nhẹ, Healthy) |
| Thời tiết | 12 món mỗi loại (Nắng, Mưa, Mát mẻ, Se lạnh, Lạnh) |
| Tâm trạng | 12 món mỗi loại (Vui vẻ, Buồn, Bực bội, Phấn khích, Chán nản) |
| Thời gian chuẩn bị | 15 món mỗi mức (≤ 15, 15–30, 30–60, > 60 phút) |

Mỗi miền có đủ 4 món cho từng thời tiết, từng tâm trạng và từng bữa ăn, nên chọn 2 tiêu chí cùng lúc vẫn có kết quả.
Giá, calo và thời gian chuẩn bị là số tham khảo. Lượt thích bắt đầu từ 0 và chỉ tăng khi người dùng bấm thích.

**Áp dụng vào database đang chạy** (chọn 1 trong 2 cách):

- Giữ tài khoản, hồ sơ, bộ lọc đã lưu: mở `database/02_seed_data.sql` trong DBeaver và chạy cả file (Alt+X).
  File này chạy lại được nhiều lần; món đã thích / đã lưu cũ bị xoá vì danh sách món thay đổi.
- Làm lại từ đầu: `docker compose down -v` rồi `docker compose up -d`.

**Ảnh món:** hiện là ảnh minh hoạ theo nhóm món (phở, bún, cơm, gỏi...), chưa phải ảnh riêng từng món.
Muốn đổi, sửa cột `image_url` của bảng `dishes` trong DBeaver; khoảng 1 phút sau app tự cập nhật.

### Quán ăn thật quanh vị trí người dùng

Không còn quán mẫu trong database. Khi mở mục **Quán ăn**, app gửi vị trí hiện tại lên backend và backend tìm theo thứ tự:

1. **Google Places** – khi `GOOGLE_PLACES_API_KEY` trong `backend/.env` có giá trị. Có điểm đánh giá, ảnh, trạng thái mở cửa.
   Chưa gõ từ khoá: liệt kê quán trong bán kính 3 km. Có từ khoá hoặc bấm "Tìm quán bán món này": tìm theo tên món.
2. **OpenStreetMap** – miễn phí, không cần key, tự dùng khi chưa có key Google (hoặc Google không trả kết quả).
   Không có điểm đánh giá và ảnh; nhiều quán chưa có địa chỉ, khi đó nút *Mở Google Maps* mở đúng toạ độ quán.
   Tắt bằng `OSM_ENABLED=false` trong `backend/.env`.
3. **Bảng `restaurants`** – để trống; bạn có thể tự thêm quán riêng (nhập đúng toạ độ), chúng được trộn vào kết quả.

Không tìm thấy quán nào thì app báo rõ và có nút *Tìm trên Google Maps*, không tự tạo quán giả.

Gắn key Google Places:

1. Google Cloud Console → tạo project → bật thanh toán → *APIs & Services* → bật **Places API**.
2. *Credentials* → *Create credentials* → *API key*. Phần *Application restrictions* để **None** (key được gọi từ backend).
3. Dán vào `backend/.env`: `GOOGLE_PLACES_API_KEY=...` rồi khởi động lại backend.
4. Mở http://localhost:8080/api/health thấy `"googlePlaces":true` là backend đã nhận key.
   Nếu key bị từ chối, log backend có dòng `Google Places trả về REQUEST_DENIED: ...` kèm lý do.

> **Máy ảo Android** mặc định báo vị trí ở Mỹ. Bấm `...` (Extended controls) → *Location* → nhập toạ độ nơi bạn ở
> (ví dụ Hà Nội: 21.0285, 105.8542) → *Set Location*, nếu không danh sách quán sẽ là quán ở Mỹ.
> Chưa cấp quyền vị trí thì app tạm tìm quanh trung tâm Hà Nội và hiện dòng nhắc bật định vị.

## Đăng nhập Google (Firebase)

App vẫn dùng Firebase **chỉ để đăng nhập Google**, dữ liệu người dùng nằm ở PostgreSQL:
app đăng nhập Google → lấy Firebase ID token → gửi `POST /api/auth/google` → backend tạo/tìm user và cấp token riêng.

- Android: thêm SHA-1 (`cd frontend/android` → `.\gradlew signingReport`) vào Firebase Console,
  bật Google Sign-In ở mục Authentication, tải lại `google-services.json` (phải có `oauth_client`) vào `frontend/android/app/`.
- Web: chạy `flutterfire configure` để tạo `firebase_options.dart`. Nếu chưa cấu hình, nút Google sẽ dùng tài khoản demo.
- Backend: khi triển khai thật, tải file service account (Project settings → Service accounts → Generate new private key),
  đặt đường dẫn vào `FIREBASE_CREDENTIALS` và đổi `ALLOW_UNVERIFIED_GOOGLE_TOKEN=false`.

## Danh sách API chính

| Phương thức | Đường dẫn | Mô tả |
|---|---|---|
| POST | `/api/auth/guest` · `/api/auth/demo` · `/api/auth/google` | Đăng nhập, trả về `token` |
| POST | `/api/auth/logout` | Đăng xuất |
| GET/PUT/DELETE | `/api/me`, `/api/me/profile`, `/api/me/preferences` | Hồ sơ, hồ sơ ăn uống/sức khoẻ, xoá tài khoản |
| GET | `/api/dishes/suggestions?region=&weather=&mood=&time=&maxTime=` | Gợi ý món (lọc theo hồ sơ) |
| GET | `/api/dishes/search?q=&category=` · `/api/dishes/featured` · `/api/dishes/{id}` | Tìm kiếm không dấu |
| GET/POST/DELETE | `/api/me/likes/{dishId}` · `/api/me/bookmarks/{dishId}` | Thích / lưu món |
| GET/POST/DELETE | `/api/me/filters` | Bộ lọc đã lưu |
| GET | `/api/restaurants?q=&dish=&category=&lat=&lng=&diet=` | Quán thật quanh (lat, lng); `q` trống = quán gần nhất. Trả kèm `source`: google / osm / local / none |
| POST | `/api/chat/messages` | Chatbot (Gemini + trả lời offline) |
| GET/DELETE | `/api/chat/sessions`, `/api/chat/sessions/{id}` | Lịch sử trò chuyện |
| GET/POST/DELETE | `/api/notifications`, `/{id}/read`, `/read-all`, `/{id}` | Thông báo |
| GET | `/api/health` | Kiểm tra backend + database |

Các API cần đăng nhập gửi header `Authorization: Bearer <token>`.

## Lỗi thường gặp

| Lỗi | Cách xử lý |
|---|---|
| Backend: `password authentication failed for user "postgres"` | `DB_PASSWORD` trong `backend/.env` phải là `postgres` (dùng Docker) |
| Backend: `Connection to localhost:5432 refused` | Docker Desktop chưa bật hoặc chưa `docker compose up -d` |
| Backend: `relation "dishes" does not exist` | Volume cũ trống: `docker compose down -v` rồi `docker compose up -d` |
| `docker compose up` báo port 5432 đã dùng | Máy có PostgreSQL khác đang chạy: tắt nó, hoặc đổi thành `"5433:5432"` trong `docker-compose.yml` và đặt `DB_PORT=5433` trong `backend/.env` |
| Backend: `JAVA_HOME not found` / `release version 17 not supported` | Đặt `JAVA_HOME` như Bước 3 (cần Java 17 trở lên) |
| Backend: `Port 8080 was already in use` | Đổi `SERVER_PORT` trong `backend/.env` (và đổi cổng trong `API_BASE_URL` của app) |
| App: "Không kết nối được máy chủ" | Backend chưa chạy / sai `API_BASE_URL` / tường lửa chặn (điện thoại thật) |
| Mục Quán ăn trống hoặc toàn quán ở nước ngoài | Máy chạy backend cần có mạng; máy ảo Android phải đặt lại vị trí (xem mục *Quán ăn thật quanh vị trí người dùng*) |
| Chatbot chỉ trả lời đơn giản | Chưa có `GEMINI_API_KEY` ở backend hoặc key hết hạn mức – bot đang dùng chế độ offline |
