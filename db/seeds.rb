orga = Organization.create({name: 'personal'})

# passwort: test123
user = User.create({email: 'matthias.wiesner@googlemail.com', password: 'dGVzdDEyMw==', organization: orga})

recipe = Recipe.create({
  organization_id: orga.id,
  title: 'Wodka Martini',
  description: "- 50 ml Grey Goose vodka\n" \
               "- 10 ml Noilly Prat\n" \
               "- ice , cube\n",
  content:     "- Fill your Martini glass with ice to chill\n" \
               "- Pour the Grey Goose Vodka and the chilled Noilly Prat vermouth into a cocktail shaker\n" \
               "- Add the ice and stir for 30 seconds\n" \
               "- Empty your glass of ice and pour in the drink through a strainer\n" \
               "- Garnish with a twist of lem\n",
  updated_by: user.id
})

tags = [
  {name: 'kräftig', organization_id: orga.id},
  {name: 'würzig', organization_id: orga.id},
  {name: 'leicht', organization_id: orga.id},
]

tags.each do |t|
  tag = Tag.create(t)
  RecipesTags.create({tag_id: tag.id, recipe_id: recipe.id})
end