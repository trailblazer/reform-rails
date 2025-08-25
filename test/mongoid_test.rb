require 'test_helper'

return unless defined?(::Mongoid)

Mongoid.configure do |config|
  config.connect_to("reform-mongoid-test")
end
require 'reform/mongoid'

module MongoidTests
  class Disc
    include Mongoid::Document
    field :title, type: String
    has_many :tunes, inverse_of: :disc
    has_and_belongs_to_many :musicians
  end

  class Musician
    include Mongoid::Document
    field :name, type: String
  end

  class Tune
    include Mongoid::Document
    include Mongoid::Timestamps
    field :title, type: String
    belongs_to :disc, inverse_of: :tunes
    belongs_to :musician
  end

  class MongoidTest < Minitest::Spec
    class TuneForm < Reform::Form
      include Reform::Form::Mongoid
      model :tune

      property :title
      property :created_at

      validates_uniqueness_of :title, scope: [:disc_id, :musician_id]
      validates :created_at, :presence => true # have another property to test if we mix up.

      property :musician do
        property :name
        validates_uniqueness_of :name # this currently also tests if Form::AR is included as a feature.
      end
    end

    let(:disc) {Disc.create(:title => "Damnation")}
    let(:musician) {Musician.create(:name => "Opeth")}
    let(:form) {TuneForm.new(Tune.new(:musician => Musician.new))}

    # it { _(form.class.i18n_scope).must_equal :mongoid }

    it "allows accessing the database" do
    end

    # uniqueness
    it "has no errors on title when title is unique for the same musician and disc" do
      form.validate("title" => "The Gargoyle", "musician_id" => musician.id, "disc" => disc.id, "created_at" => "November 6, 1966")
      assert_empty form.errors[:title]
    end

    it "has errors on title when title is taken for the same musician and disc" do
      skip "replace ActiveModel::Validations with our own, working and reusable gem."
      Tune.create(title: "Windowpane", musician_id: musician.id, disc_id: disc.id)
      form.validate("title" => "Windowpane", "musician_id" => musician.id, "disc" => disc)
      refute_empty form.errors[:title]
    end

    # nested object taken.
    it "is valid when musician name is unique" do
      _(form.validate("musician" => {"name" => "Paul Gilbert"}, "title" => "The Gargoyle", "created_at" => "November 6, 1966")).must_equal true
    end

    it "is invalid and shows error when taken" do
      Tune.delete_all
      Musician.create(:name => "Racer X")

      _(form.validate("musician" => {"name" => "Racer X"}, "title" => "Ghost Inside My Skin")).must_equal false
      _(form.errors.messages.sort).must_equal({:"musician.name" => ["has already been taken"], :created_at => ["can't be blank"]}.sort)
    end

    it "works with Composition" do
      form = Class.new(Reform::Form) do
        include Reform::Form::Mongoid
        include Reform::Form::Composition

        property :name, :on => :musician
        validates_uniqueness_of :name
      end.new(:musician => Musician.new)

      Musician.create(:name => "Bad Religion")
      _(form.validate("name" => "Bad Religion")).must_equal false
    end

    describe "#save" do
      # TODO: test 1-n?
      it "calls model.save" do
        Musician.delete_all
        form.validate("musician" => {"name" => "Bad Religion"}, "title" => "Ghost Inside My Skin")
        form.save
        _(Musician.where(:name => "Bad Religion").size).must_equal 1
      end

      it "doesn't call model.save when block is given" do
        Musician.delete_all
        form.validate("name" => "Bad Religion")
        form.save {}
        _(Musician.where(:name => "Bad Religion").size).must_equal 0
      end
    end
  end

  class PopulateWithMongoidTest < Minitest::Spec
    class DiscForm < Reform::Form

      property :title

      collection :tunes, :populate_if_empty => Tune do
        property :title
      end
    end

    let (:disc) {Disc.new(:tunes => [])}
    it do
      form = DiscForm.new(disc)

      form.validate("tunes" => [{"title" => "Straight From The Jacket"}])

      # form populated.
      _(form.tunes.size).must_equal 1
      form.tunes[0].model.must_be_kind_of Tune

      # model NOT populated.
      _(disc.tunes).must_equal []


      form.sync

      # form populated.
      _(form.tunes.size).must_equal 1
      form.tunes[0].model.must_be_kind_of Tune

      # model also populated.
      tune = disc.tunes[0]
      _(disc.tunes).must_equal [tune]
      _(tune.title).must_equal "Straight From The Jacket"


      # if ActiveRecord::VERSION::STRING !~ /^3.0/
      #   # saving saves association.
      #   form.save
      #
      #   disc.reload
      #   tune = disc.tunes[0]
      #   _(disc.tunes).must_equal [tune]
      #   _(tune.title).must_equal "Straight From The Jacket"
      # end
    end


    describe "modifying 1., adding 2." do
      let (:tune) {Tune.new(:title => "Part 2")}
      let (:disc) {Disc.create.tap {|a| a.tunes << tune}}

      it do
        skip('fails in rails 5') if self.class.rails5?
        form = DiscForm.new(disc)

        id = disc.tunes[0].id
        _(disc.tunes[0].persisted?).must_equal true
        assert id.to_s.size > 0

        form.validate("tunes" => [{"title" => "Part Two"}, {"title" => "Check For A Pulse"}])

        # form populated.
        _(form.tunes.size).must_equal 2
        form.tunes[0].model.must_be_kind_of Tune
        form.tunes[1].model.must_be_kind_of Tune

        # model NOT populated.
        _(disc.tunes).must_equal [tune]


        form.sync

        # form populated.
        _(form.tunes.size).must_equal 2

        # model also populated.
        _(disc.tunes.size).must_equal 2

        # corrected title
        _(disc.tunes[0].title).must_equal "Part Two"
        # ..but same tune.
        _(disc.tunes[0].id).must_equal id

        # and a new tune.
        _(disc.tunes[1].title).must_equal "Check For A Pulse"
        _(disc.tunes[1].persisted?).must_equal true # TODO: with << strategy, this shouldn't be saved.
      end

      describe 'using nested_models_attributes to modify nested collection' do
        class ActiveModelDiscForm < Reform::Form
          include Reform::Form::ActiveModel
          include Reform::Form::ActiveModel::FormBuilderMethods

          property :title

          collection :tunes, :populate_if_empty => Tune do
            property :title
          end
        end

        let (:disc) {Disc.create(:title => 'Greatest Hits')}
        let (:form) {ActiveModelDiscForm.new(disc)}

        it do
          skip('fails in rails 5') if self.class.rails5?
          form.validate('tunes_attributes' => {'0' => {'title' => 'Tango'}})

          # form populated.
          _(form.tunes.size).must_equal 1
          form.tunes[0].model.must_be_kind_of Tune
          _(form.tunes[0].title).must_equal 'Tango'

          # model NOT populated.
          _(disc.tunes).must_equal []

          form.save

          # nested model persisted.
          first_tune = disc.tunes[0]
          _(first_tune.persisted?).must_equal true
          assert first_tune.id.to_s.size > 0

          # form populated.
          _(form.tunes.size).must_equal 1

          # model also populated.
          _(disc.tunes.size).must_equal 1
          _(disc.tunes[0].title).must_equal 'Tango'

          form = ActiveModelDiscForm.new(disc)
          form.validate('tunes_attributes' => {'0' => {'id' => first_tune.id, 'title' => 'Tango nuevo'}, '1' => {'title' => 'Waltz'}})

          # form populated.
          _(form.tunes.size).must_equal 2
          form.tunes[0].model.must_be_kind_of Tune
          form.tunes[1].model.must_be_kind_of Tune
          _(form.tunes[0].title).must_equal 'Tango nuevo'
          _(form.tunes[1].title).must_equal 'Waltz'

          # model NOT populated.
          _(disc.tunes.size).must_equal 1
          _(disc.tunes[0].title).must_equal 'Tango'

          form.save

          # form populated.
          _(form.tunes.size).must_equal 2

          # model also populated.
          _(disc.tunes.size).must_equal 2
          _(disc.tunes[0].id).must_equal first_tune.id
          _(disc.tunes[0].persisted?).must_equal true
          _(disc.tunes[1].persisted?).must_equal true
          _(disc.tunes[0].title).must_equal 'Tango nuevo'
          _(disc.tunes[1].title).must_equal 'Waltz'
        end
      end
    end

    # it do
    #   a=Disc.new
    #   a.tunes << Tune.new(title: "Old What's His Name") # Tune does not get persisted.

    #   a.tunes[1] = Tune.new(title: "Permanent Rust")

    #   puts "@@@"
    #   puts a.tunes.inspect

    #   puts "---"
    #   a.save
    #   puts a.tunes.inspect

    #   b = a.tunes.first

    #   a.tunes = [Tune.new(title:"Biomag")]
    #   puts "\\\\"
    #   a.save
    #   a.reload
    #   puts a.tunes.inspect

    #   b.reload
    #   puts "#{b.inspect}, #{b.persisted?}"


    #   a.tunes = [a.tunes.first, Tune.new(title: "Count Down")]
    #   b = a.tunes.first
    #   puts ":::::"
    #   a.save
    #   a.reload
    #   puts a.tunes.inspect

    #   b.reload
    #   puts "#{b.inspect}, #{b.persisted?}"
    # end
  end
end
