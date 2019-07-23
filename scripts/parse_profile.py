from collections import Counter

with open('messages/prof2.txt') as f:
    content = f.read()

lines = content.split('\n')
stripped = [l.lstrip(' ') for l in lines]

def f(s):
    parts = s.split(' ')
    head = parts[0]
    tail = ' '.join(parts[1:])
    return head, tail

pairs = [f(l) for l in stripped]
pairs_stripped = [(p0, p1.lstrip(' ')) for (p0, p1) in pairs]

pairs_ints = []
for (p0, p1) in pairs_stripped:
  try:
    p = (int(p0), p1)
  except ValueError:
    continue
  pairs_ints.append(p)

pairs_sorted = list(sorted(pairs_ints, key=lambda x: x[0], reverse=True))

counter = Counter()
for (p0, p1) in pairs_sorted:
  counter[p1] += p0


new_lines = []
for k, v in counter.most_common():
  new_lines.append("%d\t%s" % (v, k))

new_content = "\n".join(new_lines)

new_file = 'messages/prof2.sorted.txt'
with open(new_file, 'w') as f:
    f.write(new_content)
print('wrote: ', new_file)
