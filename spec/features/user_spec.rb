require 'spec_helper'

feature 'User' do
  background do
    @user = create :user_confirmed,
      email: 'rodrigomageste@gmail.com',
      password: '123456'
  end

  scenario 'deve fazer login com sucesso' do
    visit root_path
    click_link 'Sign in'
    fill_in 'Email', with: 'rodrigomageste@gmail.com'
    fill_in 'Password', with: '123456'
    click_button 'Sign in'
    expect(page).to have_content('Signed in successfully.')
  end

  scenario 'deve fazer logout' do
    login_as @user
    visit root_path
    click_link 'Sign out'
    expect(page).to have_content('Signed out successfully.')
  end

  scenario 'deve criar usuário' do
    visit root_path
    click_link 'Sign in'
    click_link 'Sign up'
    fill_in 'Email', with: 'alp@gmail.com'
    fill_in 'Password', with: '123456'
    fill_in 'Password confirmation', with: '123456'
    click_button 'Sign up'
    expect(page).to have_content("A message with a confirmation link has been \
      sent to your email address. Please open the link to activate your account.")
  end

  scenario 'deve pode editar o usuario logado' do
    login_as @user
    visit root_path
    click_link @user.email
    fill_in 'Name', with: 'Rodrigo'
    fill_in 'Password', with: '1234567'
    fill_in 'Password confirmation', with: '1234567'
    fill_in 'Current password', with: '123456'
    click_button 'Update'
    expect(page).to have_content('You updated your account successfully.')
    user = User.last
    expect(user.name).to eq('Rodrigo')
  end
end
