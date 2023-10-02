# resource "aws_cognito_user_pool" "example" {
#   name = "example-user-pool"
#   username_attributes      = ["email"]
#   auto_verified_attributes = ["email"]

#   schema {
#     attribute_data_type = "String"
#     name               = "email"
#     required           = true
#     mutable            = true
#   }

#   password_policy {
#     minimum_length    = 6
#     require_lowercase = true
#     require_numbers   = true
#   }

#   account_recovery_setting {
#     recovery_mechanisms = ["verified_email"]
#   }

#   admin_create_user_config {
#     allow_admin_create_user_only = false
#   }

#   verification_message_template {
#     default_email_option = "CONFIRM_WITH_CODE"
#     email_subject        = "Account Confirmation"
#     email_message        = "Your confirmation code is {####}"
#   }

#   password_recovery_message_template {
#     email_subject = "Password recovery code for your account"
#     email_message = "Your password recovery code is {####}."
#     sms_message   = "Your password recovery code is {####}."
#   }

#   tags = {
#     Environment = "Development"
#   }
# }

# resource "aws_cognito_user_pool_client" "example_client" {
#   name             = "example-client"
#   user_pool_id     = aws_cognito_user_pool.example.id
#   generate_secret  = false
#   refresh_token_validity        = 90
#   allowed_oauth_flows_user_pool_client = true
#   allowed_oauth_scopes = ["email", "openid", "profile"]
# }