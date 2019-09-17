require "rails_helper"

RSpec.describe IndexFacade, type: :facade do
  let!(:facilitor1) do
    create :facilitator, email: "onyekachi.okereke@andela.com"
  end

  let!(:facilitor2) do
    create :facilitator, email: "robs.ron@andela.com"
  end

  let(:facade_object) { IndexFacade.new(size: 10) }

  describe "filter out lfas" do
    let(:week_one_filter) { :week_one_lfa }
    let(:week_two_filter) { :week_two_lfa }
    let(:query) do
      { program_id: 4, city: "Lagos", cycle: 34,
        week_one_lfa: facilitor1.email, week_two_lfa: "All" }
    end

    let(:city_filter) { :city }
    let(:cycle_filter) { :cycle }

    let(:week_two_query) do
      { program_id: 4, city: "Lagos", cycle: 34,
        week_one_lfa: "All", week_two_lfa: facilitor2.email }
    end

    context "when filter is passed in containing a week one lfa" do
      it "returns the week one lfa's id" do
        expect(facade_object.filter_out_lfas(week_one_filter, query)).to eq(
          [facilitor1.id]
        )
      end
    end

    context "when filter is passed in containing a week two lfa" do
      it "returns the week two lfa's id" do
        expect(facade_object.filter_out_lfas(
                 week_two_filter, week_two_query
              )).to eq [facilitor2.id]
      end
    end

    context "check filter of city and cycle" do
      it "returns filtered city center" do
        expect(facade_object.cycle_center_filter_query(
                 city_filter, query
)).to eq(centers: { name: "Lagos" })
      end

      it "returns filtered cycle center" do
        expect(facade_object.cycle_center_filter_query(
                 cycle_filter, query
)).to eq(cycles: { cycle: 34 })
      end
    end

    context "check week one and two lfa in filter" do
      it "returns filtered lfa" do
        expect(facade_object.query_filter(week_one_filter, query)).to eq(
          [facilitor1.id]
        )
      end
    end

    context "offset" do
      it "return pages params" do
        expect(facade_object.offset).to eq(0)
      end
    end

    context "phase" do
      it "check for phase id" do
        expect(facade_object.phase).to eq(1)
      end
    end

    context "check statuses" do
      it "get redis learner statuses" do
        expect(facade_object.statuses).to eq(
          [
            "In Progress", "Rejected",
            "Dropped Out", "Advanced",
            "Level Up", "Try Again",
            "Accepted", "Fast-tracked"
          ]
        )
      end
    end

    context "build filter terms" do
      it "Returns split value that has a comma" do
        expect(facade_object.build_filter_terms("St. Louis, MO")).to eq(
          ["St. Louis", " MO"]
        )
      end

      it "Returns exact value when the value does not have a comma" do
        expect(facade_object.build_filter_terms("St. Louis MO")).to eq(
          "St. Louis MO"
        )
      end

      it "Returns All when the value is null" do
        expect(facade_object.build_filter_terms("null")).to eq("All")
      end
    end
  end
end
