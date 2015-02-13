# Dumb module definition to set VERSION. Kanina uses
# [Semantic Versioniong](http://semver.org/) religiously; the patch number is
# bumped for bug fixes, minor number is bumped for new features that don't break
# backward compatibility, and major numbers are only bumped when introducing
# major API changes that break backward compatibility.
module Kanina
  VERSION = '0.6.1'
end
