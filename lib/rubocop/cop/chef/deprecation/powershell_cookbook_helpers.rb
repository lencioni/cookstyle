#
# Copyright:: 2020, Chef Software, Inc.
# Author:: Tim Smith (<tsmith@chef.io>)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
module RuboCop
  module Cop
    module Chef
      module ChefDeprecations
        # Use node['powershell']['version'] or the new powershell_version helper available in Chef Infra Client 16+ instead of the deprecated PowerShell cookbook helpers
        #
        # @example
        #
        #   # bad
        #   Powershell::VersionHelper.powershell_version?('4.0')
        #
        #   # good
        #   node['powershell']['version'].to_f == 4.0
        #
        #   # good (Chef Infra Client 16+)
        #   powershell_version == 4.0
        #
        class PowershellCookbookHelpers < Cop
          MSG = "Use node['powershell']['version'] or the new powershell_version helper available in Chef Infra Client 16+ instead of the deprecated PowerShell cookbook helpers.".freeze

          def_node_matcher :ps_cb_helper?, <<-PATTERN
          (send
            (const
              (const {cbase nil?} :Powershell) :VersionHelper) :powershell_version?
            $(...))
          PATTERN

          def on_send(node)
            ps_cb_helper?(node) do
              add_offense(node, location: :expression, message: MSG, severity: :warning)
            end
          end

          def autocorrect(node)
            lambda do |corrector|
              ps_cb_helper?(node) do |ver|
                corrector.replace(node.loc.expression, "node['powershell']['version'].to_f == #{ver.source}")
              end
            end
          end
        end
      end
    end
  end
end