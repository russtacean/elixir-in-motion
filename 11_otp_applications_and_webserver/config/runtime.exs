import Config

http_port =
  if config_env() != :test,
    do: System.get_env("TODO_HTTP_PORT", "5454"),
    else: System.get_env("TODO_TEST_HTTP_PORT", "5455")

config(:todo, http_port: String.to_integer(http_port))

db_folder =
  if config_env() != :test,
    do: System.get_env("TODO_DB_FOLDER", "./persist"),
    else: System.get_env("TODO_TEST_DB_FOLDER", "./persist_test")

config(:todo, :database, db_folder: db_folder)
