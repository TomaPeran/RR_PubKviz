-- V2__create_schema.sql
-- Pub Quiz: database schema based on the ER diagram (T-02), PostgreSQL 16

-- ---------------------------------------------------------------
-- ROLE
-- ---------------------------------------------------------------
CREATE TABLE role (
    id    BIGSERIAL    PRIMARY KEY,
    name  VARCHAR(50)  NOT NULL UNIQUE
);

INSERT INTO role (name) VALUES
    ('Administrator'),
    ('Organizer'),
    ('Participant');

-- ---------------------------------------------------------------
-- USERS
-- ---------------------------------------------------------------
CREATE TABLE users (
    id             BIGSERIAL    PRIMARY KEY,
    name           VARCHAR(100) NOT NULL,
    username       VARCHAR(50)  NOT NULL UNIQUE,
    email          VARCHAR(255) NOT NULL UNIQUE,
    password_hash  VARCHAR(255) NOT NULL,
    role_id        BIGINT       NOT NULL REFERENCES role (id),
    active         BOOLEAN      NOT NULL DEFAULT TRUE,
    registered_at  TIMESTAMPTZ  NOT NULL DEFAULT now()
);

CREATE INDEX idx_users_role ON users (role_id);

-- ---------------------------------------------------------------
-- ROLE_REQUEST
-- ---------------------------------------------------------------
CREATE TABLE role_request (
    id                      BIGSERIAL    PRIMARY KEY,
    user_id                 BIGINT       NOT NULL REFERENCES users (id),
    status                  VARCHAR(20)  NOT NULL DEFAULT 'pending'
                            CHECK (status IN ('pending', 'approved', 'rejected')),
    requested_at            TIMESTAMPTZ  NOT NULL DEFAULT now(),
    processed_by_admin_id   BIGINT       REFERENCES users (id),
    processed_at            TIMESTAMPTZ
);

CREATE INDEX idx_role_request_user   ON role_request (user_id);
CREATE INDEX idx_role_request_status ON role_request (status);

-- ---------------------------------------------------------------
-- QUIZ
-- ---------------------------------------------------------------
CREATE TABLE quiz (
    id            BIGSERIAL     PRIMARY KEY,
    organizer_id  BIGINT        NOT NULL REFERENCES users (id),
    name          VARCHAR(200)  NOT NULL,
    description   VARCHAR(2000),
    starts_at     TIMESTAMPTZ   NOT NULL,
    location      VARCHAR(255)  NOT NULL,
    max_teams     BIGINT        NOT NULL CHECK (max_teams > 0),
    status        VARCHAR(20)   NOT NULL DEFAULT 'open'
                  CHECK (status IN ('open', 'in_progress', 'finished', 'cancelled')),
    created_at    TIMESTAMPTZ   NOT NULL DEFAULT now()
);

CREATE INDEX idx_quiz_organizer ON quiz (organizer_id);
CREATE INDEX idx_quiz_status    ON quiz (status);
CREATE INDEX idx_quiz_starts_at ON quiz (starts_at);

-- ---------------------------------------------------------------
-- CATEGORY
-- ---------------------------------------------------------------
CREATE TABLE category (
    id    BIGSERIAL    PRIMARY KEY,
    name  VARCHAR(100) NOT NULL UNIQUE
);

-- ---------------------------------------------------------------
-- QUESTION
-- ---------------------------------------------------------------
CREATE TABLE question (
    id             BIGSERIAL     PRIMARY KEY,
    quiz_id        BIGINT        NOT NULL REFERENCES quiz (id) ON DELETE CASCADE,
    category_id    BIGINT        NOT NULL REFERENCES category (id),
    text           VARCHAR(1000) NOT NULL,
    correct_answer VARCHAR(500)  NOT NULL,
    points         BIGINT        NOT NULL DEFAULT 1 CHECK (points >= 0),
    position       BIGINT        NOT NULL
);

CREATE INDEX idx_question_quiz_position ON question (quiz_id, position);
CREATE INDEX idx_question_category      ON question (category_id);

-- ---------------------------------------------------------------
-- TEAM
-- ---------------------------------------------------------------
CREATE TABLE team (
    id          BIGSERIAL    PRIMARY KEY,
    name        VARCHAR(100) NOT NULL UNIQUE,
    leader_id   BIGINT       NOT NULL REFERENCES users (id),
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT now()
);

CREATE INDEX idx_team_leader ON team (leader_id);

-- ---------------------------------------------------------------
-- TEAM_MEMBER (M:N users - team)
-- ---------------------------------------------------------------
CREATE TABLE team_member (
    team_id    BIGINT      NOT NULL REFERENCES team (id) ON DELETE CASCADE,
    user_id    BIGINT      NOT NULL REFERENCES users (id),
    joined_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (team_id, user_id)
);

CREATE INDEX idx_team_member_user ON team_member (user_id);

-- ---------------------------------------------------------------
-- TEAM_REGISTRATION
-- ---------------------------------------------------------------
CREATE TABLE team_registration (
    id             BIGSERIAL   PRIMARY KEY,
    team_id        BIGINT      NOT NULL REFERENCES team (id),
    quiz_id        BIGINT      NOT NULL REFERENCES quiz (id),
    registered_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    status         VARCHAR(20) NOT NULL DEFAULT 'active'
                   CHECK (status IN ('active', 'cancelled')),
    CONSTRAINT uq_registration_team_quiz UNIQUE (team_id, quiz_id)
);

CREATE INDEX idx_registration_quiz ON team_registration (quiz_id, status);

-- ---------------------------------------------------------------
-- SCORE
-- ---------------------------------------------------------------
CREATE TABLE score (
    id               BIGSERIAL     PRIMARY KEY,
    registration_id  BIGINT        NOT NULL REFERENCES team_registration (id) ON DELETE CASCADE,
    question_id      BIGINT        NOT NULL REFERENCES question (id) ON DELETE CASCADE,
    points           NUMERIC(6, 2) NOT NULL CHECK (points >= 0),
    CONSTRAINT uq_score_registration_question UNIQUE (registration_id, question_id)
);

CREATE INDEX idx_score_question ON score (question_id);
