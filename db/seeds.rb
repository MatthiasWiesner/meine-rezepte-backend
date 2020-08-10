organization = [
  {name: 'club-laguna'},
  {name: 'barfritzn'},
  {name: 'la-leander'},
]

organization.each do |o|
  Organization.create(o)
end

users = [
  {email: 'info@club-laguna.de', password: 'Y29ja3RhaWw=', organization: Organization.find_by_name('club-laguna')},
  {email: 'matthias.wiesner@googlemail.com', password: 'dGVzdDEyMw==', organization: Organization.find_by_name('la-leander')}
]

users.each do |u|
  User.create(u)
end

tags = [
  {name: 'kräftig'},
  {name: 'würzig'},
  {name: 'leicht'},
]

tags.each do |t|
  Tag.create(t)
end

recipes = [
  {
    organization_id: 2,
    title: 'Wodka Martini',
    description: '- 50 ml Grey Goose vodka' \
                 ' - 10 ml Noilly Prat' \
                 ' - ice , cubed',
    content:     '- Fill your Martini glass with ice to chill' \
                 '- Pour the Grey Goose Vodka and the chilled Noilly Prat vermouth into a cocktail shaker' \
                 '- Add the ice and stir for 30 seconds' \
                 '- Empty your glass of ice and pour in the drink through a strainer' \
                 '- Garnish with a twist of lemo',
    updated_by: 2,
    tag_id: [1,2]
  }
]

recipes_tags = [
  {tag_id: 1, recipe_id: 1},
  {tag_id: 2, recipe_id: 1},
]

recipes_tags.each do |rt|
  TagRecipeRelationship.create(rt)
end