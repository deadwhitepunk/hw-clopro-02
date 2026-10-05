resource "yandex_storage_bucket" "pictures_bucket" {
  anonymous_access_flags {
    read        = true
    list        = false
    config_read = false
  }
  bucket = "collectionofcats"
  folder_id = var.folder_id
}

resource "yandex_storage_object" "download_kitty" {
  bucket = yandex_storage_bucket.pictures_bucket.id
  key = "best_kitty.jpg"
  source = "../img/kitty_from_internet.jpg"
}