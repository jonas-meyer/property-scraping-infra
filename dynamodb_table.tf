resource "aws_dynamodb_table" "listing_table" {
  name         = "listing-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "ListingID"
  attribute {
    name = "ListingID"
    type = "S"
  }
}