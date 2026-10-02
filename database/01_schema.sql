-- =====================================================================
--  HÔM NAY ĂN GÌ – CƠ SỞ DỮ LIỆU PostgreSQL
--  Chạy file này TRƯỚC (trong DBeaver: mở file -> Alt+X "Execute script")
--  Có thể chạy lại nhiều lần: các bảng cũ sẽ bị xoá và tạo lại.
-- =====================================================================

DROP TABLE IF EXISTS notification_states CASCADE;
DROP TABLE IF EXISTS notifications       CASCADE;
DROP TABLE IF EXISTS chat_messages       CASCADE;
DROP TABLE IF EXISTS chat_sessions       CASCADE;
DROP TABLE IF EXISTS saved_filters       CASCADE;
DROP TABLE IF EXISTS bookmarks           CASCADE;
DROP TABLE IF EXISTS liked_dishes        CASCADE;
DROP TABLE IF EXISTS restaurants         CASCADE;
DROP TABLE IF EXISTS dishes              CASCADE;
DROP TABLE IF EXISTS auth_sessions       CASCADE;
DROP TABLE IF EXISTS user_preferences    CASCADE;
DROP TABLE IF EXISTS users               CASCADE;

-- ---------------------------------------------------------------------
-- NGƯỜI DÙNG
-- ---------------------------------------------------------------------
CREATE TABLE users (
    id            BIGSERIAL    PRIMARY KEY,
    firebase_uid  VARCHAR(128) UNIQUE,              -- null với tài khoản khách / demo
    email         VARCHAR(255),
    display_name  VARCHAR(100) NOT NULL DEFAULT 'Người dùng Foodie',
    bio           TEXT         NOT NULL DEFAULT 'Yêu thích nấu ăn và khám phá ẩm thực Việt Nam.',
    avatar_url    TEXT,
    is_guest      BOOLEAN      NOT NULL DEFAULT FALSE,
    is_demo       BOOLEAN      NOT NULL DEFAULT FALSE,
    created_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

-- Hồ sơ ăn uống + sức khoẻ (1 - 1 với users)
CREATE TABLE user_preferences (
    user_id               BIGINT      PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    diet_type             VARCHAR(60) NOT NULL DEFAULT 'Bình thường',
    favorite_flavors      TEXT[]      NOT NULL DEFAULT '{}',
    budget_level          VARCHAR(30) NOT NULL DEFAULT 'Vừa',
    disliked_ingredients  TEXT[]      NOT NULL DEFAULT '{}',
    cooking_level         VARCHAR(30) NOT NULL DEFAULT 'Dễ nấu',
    kitchen_preference    VARCHAR(30) NOT NULL DEFAULT 'Tự nấu',
    default_eaters        INT         NOT NULL DEFAULT 2,
    meal_times            TEXT[]      NOT NULL DEFAULT '{"Bữa trưa","Bữa tối"}',
    allergies             TEXT[]      NOT NULL DEFAULT '{}',
    cuisines              TEXT[]      NOT NULL DEFAULT '{"Việt Nam"}',
    spiciness             VARCHAR(30) NOT NULL DEFAULT 'Cay vừa',
    dietary_restrictions  TEXT[]      NOT NULL DEFAULT '{}',
    height                DOUBLE PRECISION,             -- cm
    weight                DOUBLE PRECISION,             -- kg
    gender                VARCHAR(10),                  -- Nam / Nữ / Khác
    birth_year            INT,
    activity_level        VARCHAR(40),
    calorie_goal          INT,
    updated_at            TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Phiên đăng nhập: app gửi token trong header "Authorization: Bearer <token>"
CREATE TABLE auth_sessions (
    token         VARCHAR(64) PRIMARY KEY,
    user_id       BIGINT      NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_used_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_auth_sessions_user ON auth_sessions(user_id);

-- ---------------------------------------------------------------------
-- MÓN ĂN
-- ---------------------------------------------------------------------
CREATE TABLE dishes (
    id                   BIGSERIAL    PRIMARY KEY,
    title                VARCHAR(200) NOT NULL,
    description          TEXT         NOT NULL DEFAULT '',
    image_url            TEXT         NOT NULL DEFAULT '',
    calories             INT          NOT NULL DEFAULT 0,
    prep_time_minutes    INT          NOT NULL DEFAULT 0,
    difficulty           VARCHAR(20)  NOT NULL DEFAULT 'Dễ',        -- Dễ / Trung bình / Khó
    category             VARCHAR(30)  NOT NULL,                     -- Bữa sáng / Bữa trưa / Bữa tối / Healthy / Ăn nhẹ
    likes_count          INT          NOT NULL DEFAULT 0,
    is_special_of_week   BOOLEAN      NOT NULL DEFAULT FALSE,
    region               VARCHAR(20),                               -- Miền bắc / Miền trung / Miền nam
    weather              VARCHAR(20),                               -- Nắng / Mưa / Mát mẻ / Se lạnh / Lạnh
    mood                 VARCHAR(20),                               -- Vui vẻ / Buồn / Bực bội / Phấn khích / Chán nản
    price                INT          NOT NULL DEFAULT 35000,       -- VNĐ
    created_at           TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_dish_price CHECK (price >= 0),
    CONSTRAINT chk_dish_likes CHECK (likes_count >= 0)
);
CREATE INDEX idx_dishes_category ON dishes(category);
CREATE INDEX idx_dishes_region   ON dishes(region);

CREATE TABLE liked_dishes (
    user_id     BIGINT      NOT NULL REFERENCES users(id)  ON DELETE CASCADE,
    dish_id     BIGINT      NOT NULL REFERENCES dishes(id) ON DELETE CASCADE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (user_id, dish_id)
);

CREATE TABLE bookmarks (
    user_id     BIGINT      NOT NULL REFERENCES users(id)  ON DELETE CASCADE,
    dish_id     BIGINT      NOT NULL REFERENCES dishes(id) ON DELETE CASCADE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (user_id, dish_id)
);

-- Bộ lọc người dùng đặt tên và lưu lại
CREATE TABLE saved_filters (
    id           BIGSERIAL   PRIMARY KEY,
    user_id      BIGINT      NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name         VARCHAR(60) NOT NULL,
    time_option  VARCHAR(20) NOT NULL DEFAULT 'Bất kỳ',
    max_time     INT         NOT NULL DEFAULT 180,
    region       VARCHAR(20),
    weather      VARCHAR(20),
    mood         VARCHAR(20),
    created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE UNIQUE INDEX uq_saved_filters_name ON saved_filters(user_id, LOWER(name));

-- ---------------------------------------------------------------------
-- QUÁN ĂN tự thêm (tuỳ chọn). Quán thật quanh người dùng lấy từ Google Places / OpenStreetMap.
-- ---------------------------------------------------------------------
CREATE TABLE restaurants (
    id            BIGSERIAL    PRIMARY KEY,
    name          VARCHAR(200) NOT NULL,
    address       VARCHAR(300) NOT NULL,
    rating        DOUBLE PRECISION NOT NULL DEFAULT 4.5,
    image_url     TEXT         NOT NULL DEFAULT '',
    category      VARCHAR(30)  NOT NULL,        -- Món Chay / Healthy / Nhà hàng / Ăn vặt / Quán Nhậu
    latitude      DOUBLE PRECISION NOT NULL,
    longitude     DOUBLE PRECISION NOT NULL,
    open_minute   INT          NOT NULL DEFAULT 360,   -- phút trong ngày: 360 = 06:00
    close_minute  INT          NOT NULL DEFAULT 1320,  -- 1320 = 22:00, 1440 = 24:00
    CONSTRAINT chk_open_hours CHECK (open_minute BETWEEN 0 AND 1440 AND close_minute BETWEEN 0 AND 1440)
);
CREATE INDEX idx_restaurants_category ON restaurants(category);

-- ---------------------------------------------------------------------
-- CHATBOT
-- ---------------------------------------------------------------------
CREATE TABLE chat_sessions (
    id          BIGSERIAL   PRIMARY KEY,
    user_id     BIGINT      NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title       VARCHAR(80) NOT NULL DEFAULT 'Cuộc trò chuyện',
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_chat_sessions_user ON chat_sessions(user_id, updated_at DESC);

CREATE TABLE chat_messages (
    id              BIGSERIAL   PRIMARY KEY,
    session_id      BIGINT      NOT NULL REFERENCES chat_sessions(id) ON DELETE CASCADE,
    is_user         BOOLEAN     NOT NULL,
    content         TEXT        NOT NULL DEFAULT '',
    message_type    VARCHAR(30) NOT NULL DEFAULT 'text',   -- text / recipeList / restaurantSuggestion
    dish_ids        BIGINT[]    NOT NULL DEFAULT '{}',     -- các món được gợi ý kèm tin nhắn
    recipe_dish_id  BIGINT      REFERENCES dishes(id) ON DELETE SET NULL,
    had_image       BOOLEAN     NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_chat_messages_session ON chat_messages(session_id, id);

-- ---------------------------------------------------------------------
-- THÔNG BÁO
-- ---------------------------------------------------------------------
CREATE TABLE notifications (
    id          BIGSERIAL    PRIMARY KEY,
    user_id     BIGINT       REFERENCES users(id) ON DELETE CASCADE,  -- NULL = gửi cho tất cả
    title       VARCHAR(200) NOT NULL,
    message     TEXT         NOT NULL,
    type        VARCHAR(20)  NOT NULL DEFAULT 'update',  -- promo / personal / update
    icon        VARCHAR(40)  NOT NULL DEFAULT 'notifications',
    image_url   TEXT,
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

-- Trạng thái đã đọc / đã xoá của từng người dùng
CREATE TABLE notification_states (
    user_id          BIGINT  NOT NULL REFERENCES users(id)         ON DELETE CASCADE,
    notification_id  BIGINT  NOT NULL REFERENCES notifications(id) ON DELETE CASCADE,
    is_read          BOOLEAN NOT NULL DEFAULT FALSE,
    is_deleted       BOOLEAN NOT NULL DEFAULT FALSE,
    PRIMARY KEY (user_id, notification_id)
);
