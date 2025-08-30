class MembersComponent < ViewComponent::Base
  def initialize
    data = YAML.load_file(Rails.root.join('config', 'members.yml'))
    @institutional = Array(data['institutional'])
    @associate = Array(data['associate'])
    @provinces = (
      (@institutional + @associate).map { |m| m['province'] }.compact.uniq.sort
    )
  end
end

