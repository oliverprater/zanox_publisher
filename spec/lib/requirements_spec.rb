describe "Test requirement", :focus do
  it "a connect ID in spec/config/credentials.yml" do
    expect(credentials['connect_id']).to be_kind_of String
  end

  it "a secret key in spec/config/credentials.yml" do
    expect(credentials['secret_key']).to be_kind_of String
  end
end
