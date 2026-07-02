environment           = "prod"
namespace             = "myorg"
db_password           = "ChangeMe123!"
compliance_profile    = "hipaa"
kubernetes_version    = "1.29"
cognito_callback_urls = ["https://app.example.com/callback"]
cognito_logout_urls   = ["https://app.example.com/logout"]
# HIPAA: MFA enforced, 14-char passwords, Aurora PITR+deletion protection
