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

require_relative 'base'
require_relative '../version-update/gradle'

# The class that encapsulates releasing a Pivotal Tracker Story
class PivotalIntegration::Command::Release < PivotalIntegration::Command::Base
  desc "Create a release for a story"

  # Releases a Pivotal Tracker story by doing the following steps:
  # * Update the version to the release version
  # * Create a tag for the release version
  # * Update the version to the new development version
  # * Push tag and changes to remote
  #
  # @param [String, nil] filter a filter for selecting the release to start.  This
  #   filter can be either:
  #   * a story id
  #   * +nil+
  # @return [void]
  def run(filter)
    story = PivotalIntegration::Util::Story.select_story(@project, filter.nil? ? 'release' : filter, 1)
    PivotalIntegration::Util::Story.pretty_print story

    updater = [
      PivotalIntegration::VersionUpdate::Gradle.new(@repository_root)
    ].find { |candidate| candidate.supports? }

    current_version = updater.current_version
    release_version = ask("Enter release version (current: #{current_version}): ")
    next_version = ask("Enter next development version (current: #{current_version}): ")

    updater.update_version release_version
    PivotalIntegration::Util::Git.create_release_tag release_version, story
    updater.update_version next_version
    PivotalIntegration::Util::Git.create_commit "#{next_version} Development", story

    PivotalIntegration::Util::Git.push PivotalIntegration::Util::Git.branch_name, "v#{release_version}"
  end

end
