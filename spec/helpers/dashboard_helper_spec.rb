module DashboardHelperSpec
  def sheet_generated_data_one(file_one, file_two, file_three)
    expect(response.body).to include file_one
    expect(response.body).to include file_two
    expect(response.body).to include file_three
  end

  def sheet_generated_data_two(file_four, file_five, file_six)
    expect(response.body).to include file_four
    expect(response.body).to include file_five
    expect(response.body).to include file_six
  end
end
