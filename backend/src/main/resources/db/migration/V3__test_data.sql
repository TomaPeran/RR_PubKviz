-- V3__test_data.sql
-- Test users for local development (T-03): 1 admin, 1 organizer, 3 participants.
-- Every account has the password: PubKviz123!
-- (bcrypt hashes made with Spring Security's BCryptPasswordEncoder)

INSERT INTO users (name, username, email, password_hash, role_id)
VALUES
  ('Admin Test', 'admin', 'admin@example.com',
     '$2a$10$6tY9zbMw8uo156BaGkeLBOjjoU6bCkvfy4SKpT8xOeVhd.RDXzgbu',
     (SELECT id FROM role WHERE name = 'Administrator')),
  ('Organizer Test', 'organizer', 'org@example.com',
     '$2a$10$3O5Om/eZiWy.3fGzQ6CrsO5Y24hBK7CqT2eUTzR0OY5xBwwAZxQUi',
     (SELECT id FROM role WHERE name = 'Organizer')),
  ('Player One', 'player1', 'player1@example.com',
     '$2a$10$P95wt7aacClKBEqt.MQBJeNxdnNOoIAdv2yMhUwYFL9lLN6kEgpuW',
     (SELECT id FROM role WHERE name = 'Participant')),
  ('Player Two', 'player2', 'player2@example.com',
     '$2a$10$W3SDYf5Wv9ELL0fVpBtUpOi4S2GYcNT987mRfcsqMhvAJlHnI2yPe',
     (SELECT id FROM role WHERE name = 'Participant')),
  ('Player Three', 'player3', 'player3@example.com',
     '$2a$10$nWcJoB5SkOXOglnqS.5Ap.BX7xA2YsKsw3Bbg5IHtEvQqISAf0cd6',
     (SELECT id FROM role WHERE name = 'Participant'));
