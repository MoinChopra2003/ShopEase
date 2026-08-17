require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:addresses).dependent(:destroy) }
    it { should have_many(:orders).dependent(:destroy) }
    it { should have_many(:support_requests).dependent(:destroy) }
  end

  describe '#create_reset_digest' do
    let(:user) { create(:user) }

    it 'creates a reset token' do
      user.create_reset_digest
      expect(user.reset_token).to be_present
    end

    it 'stores token digest' do
      user.create_reset_digest
      expect(user.password_reset_token_digest).to be_present
    end

    it 'stores reset sent time' do
      user.create_reset_digest
      expect(user.password_reset_sent_at).to be_present
    end
  end

  describe '#authenticated_reset_token?' do
    let(:user) { create(:user) }

    it 'returns true for valid token' do
      user.create_reset_digest
      token = user.reset_token
      expect(user.authenticated_reset_token?(token)).to be true
    end

    it 'returns false for invalid token' do
      user.create_reset_digest
      expect(user.authenticated_reset_token?('invalid_token')).to be false
    end
  end

  describe '#reset_token_expired?' do
    let(:user) { create(:user) }

    it 'returns false if token sent recently' do
      user.create_reset_digest
      expect(user.reset_token_expired?).to be false
    end

    it 'returns true if token is expired' do
      user.create_reset_digest
      user.update(password_reset_sent_at: 3.hours.ago)
      expect(user.reset_token_expired?).to be true
    end
  end

  describe 'email normalization' do
    it 'converts email to lowercase' do
      user = create(:user, email: 'TEST@EXAMPLE.COM')
      expect(user.email).to eq('test@example.com')
    end
  end

  describe 'presence validations' do
    it 'requires a name' do
      user = build(:user, name: '')
      expect(user).not_to be_valid
    end

    it 'requires an email' do
      user = build(:user, email: '')
      expect(user).not_to be_valid
    end

    it 'requires a status' do
      user = build(:user, status: '')
      expect(user).not_to be_valid
    end
  end

  describe 'email uniqueness' do
    it 'enforces unique emails (case-insensitive)' do
      create(:user, email: 'test@example.com')
      duplicate = build(:user, email: 'TEST@EXAMPLE.COM')
      expect(duplicate).not_to be_valid
    end
  end

  describe 'has_secure_password' do
    it 'encrypts password' do
      user = create(:user, password: 'SecurePassword123!', password_confirmation: 'SecurePassword123!')
      expect(user.authenticate('SecurePassword123!')).to be_truthy
    end

    it 'rejects invalid password' do
      user = create(:user, password: 'SecurePassword123!', password_confirmation: 'SecurePassword123!')
      expect(user.authenticate('WrongPassword')).to be_falsey
    end
  end
end
