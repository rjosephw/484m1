    CREATE SEQUENCE photo_id_seq
    START WITH 1
    INCREMENT BY 1
    NOMAXVALUE
    NOCYCLE
    NOCACHE;

    CREATE SEQUENCE tag_photo_id_seq
    START WITH 1
    INCREMENT BY 1
    NOMAXVALUE
    NOCYCLE
    NOCACHE;

    CREATE SEQUENCE tag_subject_id_seq
    START WITH 1
    INCREMENT BY 1
    NOMAXVALUE
    NOCYCLE
    NOCACHE;

CREATE TABLE Users (
    user_id INTEGER PRIMARY KEY,
    first_name VARCHAR2(100) NOT NULL,
    last_name VARCHAR2(100) NOT NULL,
    year_of_birth INTEGER,
    month_of_birth INTEGER,
    day_of_birth INTEGER,
    gender VARCHAR2(100)
);

CREATE TABLE Friends (
    user1_id INTEGER NOT NULL,
    user2_id INTEGER NOT NULL,
    CONSTRAINT fk_friends_user1 FOREIGN KEY (user1_id) REFERENCES Users(user_id),
    CONSTRAINT fk_friends_user2 FOREIGN KEY (user2_id) REFERENCES Users(user_id),
);
CREATE OR REPLACE TRIGGER order_friend_pairs_trigger
BEFORE INSERT ON Friends
FOR EACH ROW
BEGIN
    IF :NEW.user1_id > :NEW.user2_id THEN
        :NEW.user1_id := :NEW.user1_id + :NEW.user2_id;
        :NEW.user2_id := :NEW.user1_id - :NEW.user2_id;
        :NEW.user1_id := :NEW.user1_id - :NEW.user2_id;
    END IF;
END;
/

CREATE TABLE Cities (
    city_id INTEGER PRIMARY KEY,
    city_name VARCHAR2(100) NOT NULL,
    state_name VARCHAR2(100) NOT NULL,
    country_name VARCHAR2(100) NOT NULL
);
ALTER TABLE Cities 
ADD CONSTRAINT unique_city_state_country 
UNIQUE (city_name, state_name, country_name);


CREATE TABLE User_Current_Cities (
    user_id INTEGER NOT NULL,
    current_city_id INTEGER NOT NULL,
    CONSTRAINT fk_user_current_cities_user FOREIGN KEY (user_id) REFERENCES Users(user_id),
    CONSTRAINT fk_user_current_cities_city FOREIGN KEY (current_city_id) REFERENCES Cities(city_id)
);

CREATE TABLE User_Hometown_Cities (
    user_id INTEGER NOT NULL,
    hometown_city_id INTEGER NOT NULL,
    CONSTRAINT fk_user_hometown_cities_user FOREIGN KEY (user_id) REFERENCES Users(user_id),
    CONSTRAINT fk_user_hometown_cities_city FOREIGN KEY (hometown_city_id) REFERENCES Cities(city_id)
);
ALTER TABLE User_Hometown_Cities
ADD CONSTRAINT unique_user_hometown UNIQUE (user_id);

CREATE TABLE Messages (
    message_id INTEGER PRIMARY KEY,
    sender_id INTEGER NOT NULL,
    receiver_id INTEGER NOT NULL,
    message_content VARCHAR2(2000) NOT NULL,
    sent_time TIMESTAMP NOT NULL,
    CONSTRAINT fk_messages_sender FOREIGN KEY (sender_id) REFERENCES Users(user_id),
    CONSTRAINT fk_messages_receiver FOREIGN KEY (receiver_id) REFERENCES Users(user_id)
);

CREATE TABLE Programs (
    program_id INTEGER PRIMARY KEY,
    institution VARCHAR2(100) NOT NULL,
    concentration VARCHAR2(100) NOT NULL,
    degree VARCHAR2(100) NOT NULL
);
ALTER TABLE Programs
ADD CONSTRAINT unique_program UNIQUE (institution, concentration, degree);

CREATE TABLE Education (
    user_id INTEGER NOT NULL,
    program_id INTEGER NOT NULL,
    program_year INTEGER NOT NULL,
    CONSTRAINT fk_education_user FOREIGN KEY (user_id) REFERENCES Users(user_id),
    CONSTRAINT fk_education_program FOREIGN KEY (program_id) REFERENCES Programs(program_id)
);
ALTER TABLE Education
ADD CONSTRAINT unique_education UNIQUE (user_id, program_id);

CREATE TABLE User_Events (
    event_id INTEGER PRIMARY KEY,
    event_creator_id INTEGER NOT NULL,
    event_name VARCHAR2(100) NOT NULL,
    event_tagline VARCHAR2(100),
    event_description VARCHAR2(100),
    event_host VARCHAR2(100),
    event_type VARCHAR2(100),
    event_subtype VARCHAR2(100),
    event_address VARCHAR2(2000),
    event_city_id INTEGER NOT NULL,
    event_start_time TIMESTAMP,
    event_end_time TIMESTAMP,
    CONSTRAINT fk_user_events_creator FOREIGN KEY (event_creator_id) REFERENCES Users(user_id),
    CONSTRAINT fk_user_events_city FOREIGN KEY (event_city_id) REFERENCES Cities(city_id)
);

CREATE TABLE Participants (
    event_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    confirmation VARCHAR2(100) NOT NULL,
    CONSTRAINT fk_participants_user FOREIGN KEY (user_id) REFERENCES Users(user_id),
    CONSTRAINT ck_participants_confirmation CHECK (confirmation IN ('Attending', 'Unsure', 'Declines', 'Not_Replied'))
);

CREATE TABLE Albums (
    album_id INTEGER PRIMARY KEY,
    album_owner_id INTEGER NOT NULL,
    album_name VARCHAR2(100) NOT NULL,
    album_created_time TIMESTAMP NOT NULL,
    album_modified_time TIMESTAMP,
    album_link VARCHAR2(2000) NOT NULL,
    album_visibility VARCHAR2(100) NOT NULL,
    cover_photo_id INTEGER NOT NULL,
    CONSTRAINT fk_albums_owner FOREIGN KEY (album_owner_id) REFERENCES Users(user_id),
    CONSTRAINT ck_albums_visibility CHECK (album_visibility IN ('Everyone', 'Friends', 'Friends_Of_Friends', 'Myself'))
);

CREATE TABLE Photos (
    photo_id INTEGER PRIMARY KEY,
    album_id INTEGER NOT NULL,
    photo_caption VARCHAR2(2000),
    photo_created_time TIMESTAMP NOT NULL,
    photo_modified_time TIMESTAMP,
    photo_link VARCHAR2(2000) NOT NULL,
    CONSTRAINT fk_photos_album FOREIGN KEY (album_id) REFERENCES Albums(album_id)
);
ALTER TABLE Albums
ADD CONSTRAINT fk_albums_cover_photo FOREIGN KEY (cover_photo_id) REFERENCES Photos(photo_id);
ALTER TABLE Albums
ADD CONSTRAINT ck_albums_visibility CHECK (album_visibility IN ('Everyone', 'Friends', 'Friends_Of_Friends', 'Myself'));

ALTER TABLE Photos
ADD CONSTRAINT fk_photos_album FOREIGN KEY (album_id) REFERENCES Albums(album_id) INITIALLY DEFERRED DEFERRABLE;
ALTER TABLE Albums
ADD CONSTRAINT fk_albums_cover_photo FOREIGN KEY (cover_photo_id) REFERENCES Photos(photo_id) INITIALLY DEFERRED DEFERRABLE;

CREATE TABLE Tags (
    tag_photo_id INTEGER NOT NULL,
    tag_subject_id INTEGER NOT NULL,
    tag_created_time TIMESTAMP NOT NULL,
    tag_x INTEGER NOT NULL,
    tag_y INTEGER NOT NULL,
    CONSTRAINT fk_tags_photo FOREIGN KEY (tag_photo_id) REFERENCES Photos(photo_id),
    CONSTRAINT fk_tags_subject FOREIGN KEY (tag_subject_id) REFERENCES Users(user_id),
    CONSTRAINT pk_tags PRIMARY KEY (tag_photo_id, tag_subject_id)
);
