# commonalities.js

Firebase = require('firebase')
F = new Firebase('https://lifestyles.firebaseio.com/')
common = {}


main = ->	
	F.child('observations').on 'value', (snap) ->
		for user, wisdom of snap.val()
			for value, learnings of wisdom
				common[value] ||= { users: 0 }
				common[value].users += 1
				for relation, assessments of learnings
					common[value][relation] ||= {}
					for relatedValue, assessment of assessments
						x = common[value][relation][relatedValue] ||= { total: 0, users: 0 }
						x.total += assessment
						x.users += 1

		# for value, learnings of common
		# 	delete common[value] if learnings.users < 2
		for value, learnings of common
			for relation, assessments of learnings
				for relatedValue, counts of assessments
					# delete learnings[relatedValue] if counts.users < 2
					delete learnings[relatedValue] if (counts.users / learnings.users) < 0.1

		prune common
		F.child('commonalities').set common
		process.exit()

prune = (parent, key, subtree) ->
	if !key
		for k, v of parent
			prune(parent, k, v)
		return
	if subtree instanceof Object
		for k, v of subtree
			prune(parent[key], k, v)
		if Object.keys(subtree).length == 0
			delete parent[key]
		return
	if subtree == null or subtree == undefined
		delete parent[key]
		return


main()
