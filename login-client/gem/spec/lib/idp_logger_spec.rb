require 'spec_helper'

RSpec.describe Muni::Login::Client::IdpLogger do
  let(:rails_logger) { instance_double(ActiveSupport::Logger) }
  let(:subj) { described_class.new }

  before do
    allow(Rails).to receive(:logger).and_return(rails_logger)
  end

  describe "#info" do
    it "logs JSON with info level" do
      expect(rails_logger).to receive(:info).with(a_string_including('"level":"info"'))
      subj.info(location: "Test", message: "test message")
    end

    it "includes gem_version and topic" do
      expect(rails_logger).to receive(:info).with(
        a_string_including(
          %("gem_version":"#{Muni::Login::Client::IdpLogger::MUNI_GEM_VERSION}"),
          '"topic":"muni_login_client"'
        )
      )
      subj.info("test")
    end
  end

  describe "#warn" do
    it "logs JSON with warn level" do
      expect(rails_logger).to receive(:warn).with(a_string_including('"level":"warn"'))
      subj.warn("warning message")
    end
  end

  describe "#error" do
    it "logs JSON with error level" do
      expect(rails_logger).to receive(:error).with(a_string_including('"level":"error"'))
      subj.error("error message")
    end
  end

  describe "#trace" do
    context "when log_trace_enabled? is true" do
      before do
        allow_any_instance_of(Muni::Login::Client::Settings)
          .to receive(:log_trace_enabled?).and_return(true)
      end

      it "logs JSON with trace level" do
        expect(rails_logger).to receive(:info).with(a_string_including('"level":"trace"'))
        subj.trace("trace message")
      end
    end

    context "when log_trace_enabled? is false" do
      before do
        allow_any_instance_of(Muni::Login::Client::Settings)
          .to receive(:log_trace_enabled?).and_return(false)
      end

      it "does not log" do
        expect(rails_logger).not_to receive(:info)
        subj.trace("trace message")
      end
    end
  end

  describe "#bind" do
    let(:idrequest) { double("IdpRequest", api_vector: "test_vector", action_signature: "test#action") }

    it "binds the idrequest for context" do
      subj.bind(idrequest: idrequest)
      expect(rails_logger).to receive(:info).with(
        a_string_including('"api_vector":"test_vector"', '"action_signature":"test#action"')
      )
      subj.info("test")
    end
  end
end
