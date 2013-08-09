require "spec_helper"

describe UserMailer do
  describe "mail_add_user" do
    let(:project) { create(:project) }
    let(:user) { create(:user_confirmed) }
    let(:mail) { UserMailer.mail_add_user(user, project) }

    it "renders the headers" do
      mail.subject.should eq('You have been added to a project at TicTracking')
      mail.to.should include(user.email)
      mail.from.should include('no-reply@tictracking.com')
    end

    it "renders the body" do
      mail.body.encoded.should have_content("You have been added to the project #{project.name}")
      mail.body.encoded.should have_link(project.name, href: project_url(project))
    end
  end
end
