CREATE TABLE IF NOT EXISTS video_ratings_by_user (
    videoid uuid,
    userid uuid,
    rating int,
    PRIMARY KEY (videoid, userid)
);