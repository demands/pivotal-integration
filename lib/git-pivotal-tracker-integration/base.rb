# Git Pivotal Tracker Integration
# Copyright (c) 2013 the original author or authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "git-pivotal-tracker-integration/pivotal_configuration"
require "pivotal-tracker"

class Base

  def initialize
    PivotalTracker::Client.token = PivotalConfiguration.api_token
    PivotalTracker::Client.use_ssl = true
  end

  protected

  def current_branch
    exec("git branch").scan(/\* (.*)/)[0][0]
  end

  def exec(command)
    result = `#{command}`
    if $?.exitstatus != 0
      abort "FAIL"
    end

    result
  end

end