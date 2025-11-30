RESTIC_REPOSITORY_FILE              Name of file containing the repository location (replaces --repository-file)
RESTIC_REPOSITORY                   Location of repository (replaces -r)
RESTIC_PASSWORD_FILE                Location of password file (replaces --password-file)
RESTIC_PASSWORD                     The actual password for the repository
RESTIC_PASSWORD_COMMAND             Command printing the password for the repository to stdout
RESTIC_KEY_HINT                     ID of key to try decrypting first, before other keys
RESTIC_CACERT                       Location(s) of certificate file(s), comma separated if multiple (replaces --cacert)
RESTIC_TLS_CLIENT_CERT              Location of TLS client certificate and private key (replaces --tls-client-cert)
RESTIC_CACHE_DIR                    Location of the cache directory
RESTIC_COMPRESSION                  Compression mode (only available for repository format version 2)
RESTIC_HOST                         Only consider snapshots for this host / Set the hostname for the snapshot manually (replaces --host)
RESTIC_PROGRESS_FPS                 Frames per second by which the progress bar is updated
RESTIC_PACK_SIZE                    Target size for pack files
RESTIC_READ_CONCURRENCY             Concurrency for file reads

TMPDIR                              Location for temporary files (except Windows)
TMP                                 Location for temporary files (only Windows)

AWS_ACCESS_KEY_ID                   Amazon S3 access key ID
AWS_SECRET_ACCESS_KEY               Amazon S3 secret access key
AWS_SESSION_TOKEN                   Amazon S3 temporary session token
AWS_DEFAULT_REGION                  Amazon S3 default region
AWS_PROFILE                         Amazon credentials profile (alternative to specifying key and region)
AWS_SHARED_CREDENTIALS_FILE         Location of the AWS CLI shared credentials file (default: ~/.aws/credentials)
RESTIC_AWS_ASSUME_ROLE_ARN          Amazon IAM Role ARN to assume using discovered credentials
RESTIC_AWS_ASSUME_ROLE_SESSION_NAME Session Name to use with the role assumption
RESTIC_AWS_ASSUME_ROLE_EXTERNAL_ID  External ID to use with the role assumption
RESTIC_AWS_ASSUME_ROLE_POLICY       Inline Amazion IAM session policy
RESTIC_AWS_ASSUME_ROLE_REGION       Region to use for IAM calls for the role assumption (default: us-east-1)
RESTIC_AWS_ASSUME_ROLE_STS_ENDPOINT URL to the STS endpoint (default is determined based on RESTIC_AWS_ASSUME_ROLE_REGION). You generally do not need to set this, advanced use only.

AZURE_ACCOUNT_NAME                  Account name for Azure
AZURE_ACCOUNT_KEY                   Account key for Azure
AZURE_ACCOUNT_SAS                   Shared access signatures (SAS) for Azure
AZURE_ENDPOINT_SUFFIX               Endpoint suffix for Azure Storage (default: core.windows.net)
AZURE_FORCE_CLI_CREDENTIAL          Force the use of Azure CLI credentials for authentication

B2_ACCOUNT_ID                       Account ID or applicationKeyId for Backblaze B2
B2_ACCOUNT_KEY                      Account Key or applicationKey for Backblaze B2

GOOGLE_PROJECT_ID                   Project ID for Google Cloud Storage
GOOGLE_APPLICATION_CREDENTIALS      Application Credentials for Google Cloud Storage (e.g. $HOME/.config/gs-secret-restic-key.json)

OS_AUTH_URL                         Auth URL for keystone authentication
OS_REGION_NAME                      Region name for keystone authentication
OS_USERNAME                         Username for keystone authentication
OS_USER_ID                          User ID for keystone v3 authentication
OS_PASSWORD                         Password for keystone authentication
OS_TENANT_ID                        Tenant ID for keystone v2 authentication
OS_TENANT_NAME                      Tenant name for keystone v2 authentication

OS_USER_DOMAIN_NAME                 User domain name for keystone authentication
OS_USER_DOMAIN_ID                   User domain ID for keystone v3 authentication
OS_PROJECT_NAME                     Project name for keystone authentication
OS_PROJECT_DOMAIN_NAME              Project domain name for keystone authentication
OS_PROJECT_DOMAIN_ID                Project domain ID for keystone v3 authentication
OS_TRUST_ID                         Trust ID for keystone v3 authentication

OS_APPLICATION_CREDENTIAL_ID        Application Credential ID (keystone v3)
OS_APPLICATION_CREDENTIAL_NAME      Application Credential Name (keystone v3)
OS_APPLICATION_CREDENTIAL_SECRET    Application Credential Secret (keystone v3)

OS_STORAGE_URL                      Storage URL for token authentication
OS_AUTH_TOKEN                       Auth token for token authentication

RCLONE_BWLIMIT                      rclone bandwidth limit

RESTIC_REST_USERNAME                Restic REST Server username
RESTIC_REST_PASSWORD                Restic REST Server password

ST_AUTH                             Auth URL for keystone v1 authentication
ST_USER                             Username for keystone v1 authentication
ST_KEY                              Password for keystone v1 authentication
