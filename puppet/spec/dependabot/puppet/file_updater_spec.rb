# frozen_string_literal: true

require "spec_helper"
require "dependabot/dependency"
require "dependabot/dependency_file"
require "dependabot/puppet/file_updater"
require "dependabot/shared_helpers"
require_common_spec "file_updaters/shared_examples_for_file_updaters"

RSpec.describe Dependabot::Puppet::FileUpdater do
  it_behaves_like "a dependency file updater"

  let(:updater) do
    described_class.new(
      dependency_files: files,
      dependencies: [dependency, dependency2],
      credentials: [{
        "type" => "git_source",
        "host" => "github.com",
        "username" => "x-access-token",
        "password" => "token"
      }]
    )
  end

  let(:files) { [puppet_file] }
  let(:puppet_file) do
    Dependabot::DependencyFile.new(name: "Puppetfile", content: puppet_file_body)
  end
  let(:puppet_file_body) { fixture("puppet", puppet_file_fixture_name) }
  let(:puppet_file_fixture_name) { "Puppetfile" }

  let(:dependency) do
    Dependabot::Dependency.new(
      name: "puppetlabs/dsc",
      version: "1.9.0",
      requirements: [{
        file: "Puppetfile",
        requirement: "1.9.0",
        groups: [],
        source: {
          type: "default",
          source: "puppetlabs/dsc"
        }
      }],
      previous_version: "1.4.0",
      previous_requirements: [{
        file: "Puppetfile",
        requirement: "1.4.0",
        groups: [],
        source: {
          type: "default",
          source: "puppetlabs/dsc"
        }
      }],
      package_manager: "puppet"
    )
  end
  let(:dependency2) do
    Dependabot::Dependency.new(
      name: "puppet/windowsfeature",
      version: "3.2.0",
      requirements: [{
        file: "Pupeptfile",
        requirement: "3.2.0",
        groups: [],
        source: {
          type: "default",
          source: "puppet/windowsfeature"
        }
      }],
      previous_version: "2.0.0",
      previous_requirements: [{
        file: "Pupeptfile",
        requirement: "2.0.0",
        groups: [],
        source: {
          type: "default",
          source: "puppet/windowsfeature"
        }
      }],
      package_manager: "puppet"
    )
  end
  let(:tmp_path) { Dependabot::SharedHelpers::BUMP_TMP_DIR_PATH }

  before { Dir.mkdir(tmp_path) unless Dir.exist?(tmp_path) }

  describe "#updated_dependency_files" do
    subject(:updated_files) { updater.updated_dependency_files }

    it "doesn't store the files permanently, and returns DependencyFiles" do
      expect { updated_files }.to_not(change { Dir.entries(tmp_path) })
      updated_files.each { |f| expect(f).to be_a(Dependabot::DependencyFile) }
    end

    it { expect { updated_files }.to_not output.to_stdout }

    it "includes an updated Puppetfile" do
      expect(updated_files.find { |f| f.name == "Puppetfile" }).to_not be_nil
    end

    # it "only changes 1 line" do
    #   expect(changed_file).to_not be_nil
    # end

  end
end
