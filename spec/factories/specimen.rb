require 'spec_helper'

FactoryGirl.define do
  sequence :current_label do |n|
    sprintf '%05d', n
  end

  factory :specimen, class: Specimen do
    study_id        "STUDY1"
    subject_id      "12345"
    specimen_type   "WB"
    current_label
    billing_method  "Direct Billing"
    date_drawn      "06/14/2013 00:00"
    date_received   "06/14/2013 05:00"
    label_status    "Barcoded"
    thaws           '0'

    # Generic Fluid Specimen
    trait :fluid do
      specimen_type "WB"
    end

    # Generic Slide Specimen
    trait :slide do
      specimen_type "SLDTS"
    end

    factory :slide_specimen, traits: [:slide]
  end
end
