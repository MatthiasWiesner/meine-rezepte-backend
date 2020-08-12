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
  {name: 'kräftig', organization_id: 2},
  {name: 'würzig', organization_id: 2},
  {name: 'leicht', organization_id: 2},
]

tags.each do |t|
  Tag.create(t)
end

recipes = [
  {
    organization_id: 2,
    title: 'Wodka Martini',
    description: "- 50 ml Grey Goose vodka\n" \
                 "- 10 ml Noilly Prat\n" \
                 "- ice , cube\n",
    content:     "- Fill your Martini glass with ice to chill\n" \
                 "- Pour the Grey Goose Vodka and the chilled Noilly Prat vermouth into a cocktail shaker\n" \
                 "- Add the ice and stir for 30 seconds\n" \
                 "- Empty your glass of ice and pour in the drink through a strainer\n" \
                 "- Garnish with a twist of lem\n",
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