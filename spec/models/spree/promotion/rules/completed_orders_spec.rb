require 'spec_helper'

describe Spree::Promotion::Rules::CompletedOrders, type: :model do
  let(:rule) { Spree::Promotion::Rules::CompletedOrders.new }

  before do
    rule.preferred_completed_orders = 3
  end

  context '#eligible?(order)' do
    let(:user) { create(:user) }
    let(:order) { Spree::Order.new }

    it 'is eligible if user have completed orders' do
      orders = 3.times.collect { create(:completed_order_with_totals, user: user) }
      allow(order).to receive_messages(user: user)

      expect(rule).to be_eligible(order)
    end

    it 'is not eligible if user doesnt have enough completed orders' do
      orders = 2.times.collect { create(:completed_order_with_totals, user: user) }
      allow(order).to receive_messages(user: user)

      expect(rule).to_not be_eligible(order)
      expect(rule.eligibility_errors.full_messages.first).
          to eq 'You need atleast 3 completed orders before applying this coupon code.'
    end

    context 'when user is not logged in' do
      before { allow(order).to receive_messages(user: nil) } # better to be explicit here
      it { expect(rule).not_to be_eligible(order) }
      it 'sets an error message' do
        rule.eligible?(order)
        expect(rule.eligibility_errors.full_messages.first).
          to eq 'You need to login before applying this coupon code.'
      end
    end
  end
end