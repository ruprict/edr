require 'spec_helper'
require_relative '../../lib/edr/registry'

describe Edr::Registry do
  class HasAModelData < ActiveRecord::Base; end
  class HasAModel; end

  context "defining domain model to active record mappings" do
    subject { Edr::Registry }

    before do
      subject.map_model_class_to_data_class(HasAModel, HasAModelData)
    end

    it "maps every AR::Base with a class name ending in 'Data' to a domain model class with the same name less 'Data'" do
      expect(subject.model_class_for(HasAModelData)).to eq(HasAModel)
    end
  end
end
