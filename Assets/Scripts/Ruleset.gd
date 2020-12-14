extends Node


const all = [-1, 0, 1, 2]
const any = -100
const x = any


#t, d, l, r : <list of possible tiles>
#var possible = {
#	-1: [[0, 0, 0, 0]],
#	1: [[1, 1, 1, 1], [1, 0, 0, 0], [0, 1, 0, 0], [0, 0, 1, 0], [0, 0, 0, 0]],
#	0: [[0, 0, 0, 0], [0, x, x, x], [x, 0, x, x], [x, x, 0, x], [x, x, x, 0]],
#	3: [[x, x, 3, 3], [-1, -1, -1, -1], [4, x, 3, x]], # [1, 1, 1, 1]
#	4: [[4, 4, x, x], [4, -1, x, x], [-1, 4, x, x], [-1, -1, -1, -1]], # [1, 1, 1, 1]
#}

var possible = {
	-1: [[0, 0, 0, 0]],
	3: [[3, 3, -1, -1]],
	4: [[5, 5, 5, 5]]
}


func getAvailable(neighbours = [], available = []):
	var out = []
	for i in available:
		var ruleset = possible[i]
		for ni in range(neighbours.size()):
			var n = neighbours[ni]
			if str(n) != "":
				var possible = false
				var possible_overide = false
				for r in ruleset:
					var s = r[ni]
					if s == n.state or s == any:
						possible = true
					else:
						possible = false
						possible_overide = true
				if possible and not possible_overide:
					if not i in out:
						out.append(i)
	return out
func _ready():
	print("Ruleset registered.")
#	var neigh = [tileBasic]
#	print("Ruletest ()")
