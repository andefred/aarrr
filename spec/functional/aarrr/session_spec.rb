require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

require 'rack'

module AARRR
  describe Session do

    describe "#new" do
      it "should create a session with no data" do
        session = Session.new
        AARRR.users.count.should eq(1)
      end

      it "should create a session with a request env" do
        session = Session.new
        Session.new({
          "HTTP_COOKIE" => "_utmarr=#{session.id}; path=/;"
        })
        AARRR.users.count.should eq(1)

        session = Session.new({
          "HTTP_COOKIE" => "_utmarr=x83y1; path=/;"
        })

        AARRR.users.count.should eq(2)
      end
    end

    describe "tracking" do
      before(:each) do
        @session = Session.new
      end

      it "should track a custom event" do
        @session.track!(:something)

        AARRR.events.count.should eq(1)
      end

      it "should track a acquisition event" do
        @session.acquisition!(:something)
        AARRR.events.find('event_type' => "acquisition").count.should eq(1)
      end

      it "should track a activation event" do
        @session.activation!(:something)
        AARRR.events.find('event_type' => "activation").count.should eq(1)
      end

      it "should track a retention event" do
        @session.retention!(:something)
        AARRR.events.find('event_type' => "retention").count.should eq(1)
      end

      it "should track a referral event" do
        @session.referral!(:something)
        AARRR.events.find('event_type' => "referral").count.should eq(1)
      end

      it "should track a revenue event" do
        @session.revenue!(:something)
        AARRR.events.find('event_type' => "revenue").count.should eq(1)
      end

    end

    describe "Referral tracking" do
      it "should return a referral code when sending a referral and store the event" do
        @session = Session.new
        options = {}
        options["data"] = {"sent" => {"email" => "someone@somewhere.com"}}
        referral_code = @session.sent_referral!(:something, options)
        referral_code.should_not be_empty

        AARRR.events.find('referral_code' => referral_code).count.should eq(1)
      end

      it "should include data with email sent to" do
        @session = Session.new
        options = {}
        options["data"] = {"sent" => {"email" => "someone@somewhere.com"}}
        referral_code = @session.sent_referral!(:something, options)
        
        event = AARRR.events.find_one('event_type' => "sent_referral")
        event["data"].should eq(options["data"])
      end

      it "should track a referral when a request with a referral code is present" do
        @session = Session.new
        options = {}
        options["data"] = {"sent" => {"email" => "someone@somewhere.com"}}
        referral_code = @session.sent_referral!(:something, options)
        
        AARRR.events.find('referral_code' => referral_code, 'complete'=>false).count.should eq(1)

        @session.accept_referral!(referral_code)

        AARRR.events.find('referral_code' => referral_code, 'complete'=>false).count.should eq(0)
        AARRR.events.find('referral_code' => referral_code, 'complete'=>true).count.should eq(1)

      end

    end

    describe "saving" do
      it "should save the session to cookie" do
        @session = Session.new
        @session.track!(:some_event)

        # save session to response
        response = Rack::Response.new "some body", 200, {}
        @session.set_cookie(response)

        response.header["Set-Cookie"].should include("_utmarr=#{@session.id}")
      end
    end

  end
end