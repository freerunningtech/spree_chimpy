require 'spec_helper'

describe Spree::Chimpy::Subscription do
  let(:model){ double(:model) }
  let(:subscription){ described_class.new(model) }

  context 'configured' do
    before do
      Spree::Chimpy::Config.merge_vars = {'EMAIL' => :email}
      Spree::Chimpy.stub(:configured? => true)
    end

    describe "subscribe" do
      after(:each){ subscription.subscribe.should be_true }
      context 'not subscribed' do
        let(:model){ double(:model, subscribed: false) }
        it 'does nothing' do
          Spree::Chimpy.should_not_receive(:enqueue)
        end
      end
      context 'subscribed' do
        let(:model){ double(:model, subscribed: true) }
        it 'should enqueue' do
          Spree::Chimpy.should_receive(:enqueue).with(:subscribe, model)
        end
      end
    end

    describe "unsubscribe" do
      after(:each){ subscription.unsubscribe.should be_true }
      context 'not subscribed' do
        let(:model){ double(:model, subscribed: false) }
        it 'should enqueue' do
          Spree::Chimpy.should_receive(:enqueue).with(:unsubscribe, model)
        end
      end
      context 'subscribed' do
        let(:model){ double(:model, subscribed: true) }
        it 'should enqueue' do
          Spree::Chimpy.should_receive(:enqueue).with(:unsubscribe, model)
        end
      end
    end

    describe "resubscribe" do
      after(:each){ subscription.resubscribe.should be_true }
      context 'subscribed' do
        context 'unchanged' do
          let(:model){ double(:model, :subscribed => true,
                                      :subscribed_changed? => false,
                                      :email_changed? => false) }
          it 'does nothing' do
            Spree::Chimpy.should_not_receive(:enqueue)
          end
        end
        context 'changed' do
          let(:model){ double(:model, :subscribed => true,
                                      :subscribed_changed? => true,
                                      :email_changed? => false) }
          it 'subscribes' do
            Spree::Chimpy.should_receive(:enqueue).with(:subscribe, model)
          end
        end
        context 'email changed' do
          let(:model){ double(:model, :subscribed => true,
                                      :subscribed_changed? => false,
                                      :email_changed? => true) }
          it 'subscribes' do
            Spree::Chimpy.should_receive(:enqueue).with(:subscribe, model)
          end
        end
      end
      context 'not subscribed' do
        context 'unchanged' do
          let(:model){ double(:model, :subscribed => false,
                                      :subscribed_changed? => false) }
          it 'does nothing' do
            Spree::Chimpy.should_not_receive(:enqueue)
          end
        end
        context 'changed' do
          let(:model){ double(:model, :subscribed => false,
                                      :subscribed_changed? => true) }
          it 'should unsubscribe' do
            Spree::Chimpy.should_receive(:enqueue).with(:unsubscribe, model)
          end
        end
      end
    end
  end

  context 'not configured' do
    before do
      Spree::Chimpy.stub(configured?: false)
      Spree::Chimpy.should_not_receive(:enqueue)
    end

    describe 'subscribe' do
      it "does nothing" do
        subscription.subscribe
      end
    end
    describe 'unsubscribe' do
      it "does nothing" do
        subscription.unsubscribe
      end
    end
    describe 'resubscribe' do
      it "does nothing" do
        subscription.resubscribe
      end
    end
  end
end
