require "spec_helper"

describe UserMailer do
  describe "mail_add_user" do
    let(:mail) { UserMailer.mail_add_user }

    it "renders the headers" do
      mail.subject.should eq("Mail add user")
      mail.to.should eq(["to@example.org"])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("Hi")
    end
  end

end
