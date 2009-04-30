#!/usr/bin/ruby -Ku

# リンクを正しいものに差し替えたい
# マッチングされなかった枠のあまりをまとめて表示したい

require 'rubygems'
require 'hpricot'
require 'open-uri'
require 'nkf'

list = Hpricot(open('show_list.html').read)
waku = Hpricot(open('recruit2009-suisen-jokyo.html').read)
#list = Hpricot(
#  NKF.nkf('-w', open('http://www.agusa.nuie.nagoya-u.ac.jp/job10/show_list.php').read)
#)
#waku = Hpricot(
#  NKF.nkf('-w', open('http://133.6.202.192:8080/recruit2009/recruit2009-suisen-jokyo.jsp').read)
#)

free = Hpricot::Elements.new

(list/:tr).each do |row|
  if row.containers.length == 9
    if row.containers[0].name == "th"
      row.containers[1].after('<th>可否</th>')
      row.containers[2].after('<th>残枠</th>')
      next
    elsif row.containers[3].inner_text == '自由'
      free.push(row)
      next
    end
    name = row.containers[1].inner_text
    row.containers[1].inner_html = "<a href=\"http://www.google.com/search?hl=ja&q=#{name}&lr=lang_ja\" target=\"_blank\">#{name}</a>"

    $matched = Array.new()
    i = 0
    (waku/:tr).each do |comp|
      if comp.containers[0].name == 'th'
        i += 1
        next
      elsif comp.containers[0].inner_text != name
        i += 1
        next
      end
      $matched[i] = true
      kahi = comp.containers[1]
      nokori = comp.containers[2]
      children = row.containers
      children.insert(2,kahi)
      children.insert(3,nokori)
      row.children = children
      i += 1
    end
  end
end
free.remove

unmatchedtable = Hpricot(
  '<table border="1">
    <tbody>
        <tr>
           <th>社名</th>
           <th>可否</th>
           <th>残枠</th>
        </tr>
    </tbody>
</table>')
for i in 0...(waku/:tr).length do
  if $matched[i] != true
    unmatchedtable.search('/table/tbody/tr').after( (waku/:tr)[i].html )
  end
end
list.search('/table').after(unmatchedtable.html)
print list.to_html

