package info

import "fmt"

var (
	BUILD_GO_VERSION = "unknown"
	BUILD_TIME       = "unknown"
	BUILD_VERSION    = "unknown"
	BUILD_COMMIT_LOG = "unknown"
	BUILD_OS         = "unknown"
	BUILD_USERNAME   = "unknown"
)

func GetBuildInfo() string {
	return fmt.Sprintf("version %s.%s-%s\n%s\nbuild by %s on %s",
		BUILD_VERSION,
		BUILD_TIME,
		BUILD_COMMIT_LOG,
		BUILD_GO_VERSION,
		BUILD_USERNAME,
		BUILD_OS)
}
