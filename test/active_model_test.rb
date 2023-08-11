require 'test_helper'

module IsolatedRailsEngine
  def self.use_relative_model_naming?
    true
  end

  class Lyric < ActiveRecord::Base
  end
end

module NormalRailsEngine
  class Lyric < ActiveRecord::Base
  end
end


class NewActiveModelTest < Minitest::Spec # TODO: move to test/rails/
  class SongForm < Reform::Form
    include Reform::Form::ActiveModel

    property :name
  end

  let (:artist) { Artist.create(:name => "Frank Zappa") }
  let (:form) { SongForm.new(artist) }

  it do
    _(form.persisted?).must_equal true
    _(form.to_key).must_equal [artist.id]
    _(form.to_param).must_equal "#{artist.id}"
    _(form.to_model).must_equal form
    _(form.id).must_equal artist.id
    _(form.model_name).must_equal form.class.model_name
  end

  describe "::model_name" do
    it { _(form.class.model_name).must_be_kind_of ActiveModel::Name }
    it { _(form.class.model_name.to_s).must_equal "NewActiveModelTest::Song" }

    let (:class_with_model) {
      Class.new(Reform::Form) do
        include Reform::Form::ActiveModel

        model :album
      end
    }

    it { _(class_with_model.model_name).must_be_kind_of ActiveModel::Name }
    it { _(class_with_model.model_name.to_s).must_equal "Album" }

    let (:class_with_isolated_model) {
      Class.new(Reform::Form) do
        include Reform::Form::ActiveModel

        model "isolated_rails_engine/lyric", namespace: "isolated_rails_engine"
      end
    }

    it { _(class_with_isolated_model.model_name).must_be_kind_of ActiveModel::Name }
    it { _(class_with_isolated_model.model_name.to_s).must_equal "IsolatedRailsEngine::Lyric" }

    let (:class_with_namespace_model) {
      Class.new(Reform::Form) do
        include Reform::Form::ActiveModel

        model "normal_rails_engine/lyric"
      end
    }

    it { _(class_with_namespace_model.model_name).must_be_kind_of ActiveModel::Name }
    it { _(class_with_namespace_model.model_name.to_s).must_equal "NormalRailsEngine::Lyric" }

    let (:subclass_of_class_with_model) {
      Class.new(class_with_model)
    }

    it { _(subclass_of_class_with_model.model_name).must_be_kind_of ActiveModel::Name }
    it { _(subclass_of_class_with_model.model_name.to_s).must_equal 'Album' }

    it { _(form.class.model_name.route_key).must_equal "new_active_model_test_songs" }
    it { _(class_with_model.model_name.route_key).must_equal "albums" }
    it { _(class_with_isolated_model.model_name.route_key).must_equal "lyrics" }
    it { _(class_with_namespace_model.model_name.route_key).must_equal "normal_rails_engine_lyrics" }
    it { _(subclass_of_class_with_model.model_name.route_key).must_equal 'albums' }

    describe "class named Song::Form" do
      it do
        _(class Form < Reform::Form
          include Reform::Form::ActiveModel
          self
        end.model_name.to_s).must_equal "NewActiveModelTest"
      end
    end


    describe "inline with model" do
      let (:form_class) {
        Class.new(Reform::Form) do
          include Reform::Form::ActiveModel

          property :song do
            include Reform::Form::ActiveModel
            model :hit
          end
        end
      }

      let (:inline) { form_class.new(OpenStruct.new(:song => Object.new)).song }

      it { _(inline.class.model_name).must_be_kind_of ActiveModel::Name }
      it { _(inline.class.model_name.to_s).must_equal "Hit" }
    end

    describe "inline without model" do
      let (:form_class) {
        Class.new(Reform::Form) do
          include Reform::Form::ActiveModel

          property :song do
            include Reform::Form::ActiveModel
          end

          collection :hits do
            include Reform::Form::ActiveModel
          end
        end
      }

      let (:form) { form_class.new(OpenStruct.new(:hits=>[OpenStruct.new], :song => OpenStruct.new)) }

      it { _(form.song.class.model_name).must_be_kind_of ActiveModel::Name }
      it { _(form.song.class.model_name.to_s).must_equal "Song" }
      it "singularizes collection name" do
        _(form.hits.first.class.model_name.to_s).must_equal "Hit"
      end
    end
  end
end

class ActiveModelWithNilModel < MiniTest::Spec
  class SongForm < Reform::Form
    include Reform::Form::ActiveModel
    include Reform::Form::NotPersisted

    property :name, virtual: true
  end

  let (:form) { SongForm.new(nil) }

  it do
    form.persisted?.must_equal false
    form.to_key.must_equal nil
    form.to_param.must_equal nil
    form.to_model.must_equal form
    form.id.must_equal nil
    form.model_name.must_equal form.class.model_name
  end
end

class ActiveModelWithCompositionTest < Minitest::Spec
   class HitForm < Reform::Form
    include Composition
    include Reform::Form::ActiveModel

    property  :title,         :on => :song
    properties :name, :genre, :on => :artist # we need to check both ::property and ::properties here!

    model :hit, :on => :song
  end

  let (:rio) { OpenStruct.new(:title => "Rio") }
  let (:duran) { OpenStruct.new }
  let (:form) { HitForm.new(:song => rio, :artist => duran) }

  describe "model accessors a la model#[:hit]" do
    it { _(form.model[:song]).must_equal rio }
    it { _(form.model[:artist]).must_equal duran }

    it "doesn't delegate when :on missing" do
      _(class SongOnlyForm < Reform::Form
        include Composition
        include Reform::Form::ActiveModel

        property :title,  :on => :song

        model :song
      end.new(:song => rio, :artist => duran).model[:song]).must_equal rio
    end
  end


  it "provides ::model_name" do
    _(form.class.model_name).must_equal "Hit"
  end

  it "provides #persisted?" do
    _(HitForm.new(:song => OpenStruct.new.instance_eval { def persisted?; "yo!"; end; self }, :artist => OpenStruct.new).persisted?).must_equal "yo!"
  end

  it "provides #to_key" do
    _(HitForm.new(:song => OpenStruct.new.instance_eval { def to_key; "yo!"; end; self }, :artist => OpenStruct.new).to_key).must_equal "yo!"
  end

  it "provides #to_param" do
    _(HitForm.new(:song => OpenStruct.new.instance_eval { def to_param; "yo!"; end; self }, :artist => OpenStruct.new).to_param).must_equal "yo!"
  end

  it "provides #to_model" do
    form = HitForm.new(:song => OpenStruct.new, :artist => OpenStruct.new)
    _(form.to_model).must_equal form
  end

  it "works with any order of ::model and ::property" do
    class AnotherForm < Reform::Form
      include Composition
      include Reform::Form::ActiveModel

      model :song, :on => :song
      property  :title,  :on => :song
    end


    _(AnotherForm.new(:song => rio).model[:song]).must_equal rio
  end
end
