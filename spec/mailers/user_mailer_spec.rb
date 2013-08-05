require "spec_helper"

describe UserMailer do
  describe "mail_add_user" do
    let(:mail) { UserMailer.mail_add_user(nil, nil) }

    it "renders the headers" do
      pending('do it')
      mail.subject.should eq("Mail add user")
      mail.to.should eq(["to@example.org"])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      pending('do it')
      mail.body.encoded.should match("Hi")
    end
  end
end
