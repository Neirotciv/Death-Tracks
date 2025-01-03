local newAngle = self.angle + 180
          if newAngle >= 360 then
            newAngle = newAngle - 360
          end
          if self.angle < newAngle then
            self.angle = self.angle + 90 * dt
          end
          -- Suppression des éléments de la liste pour éviter un effet ping pong
          for i=#self.pathPoints, 1, -1 do
            table.remove(self.pathPoints, i)
          end
          --self.state = "MOVE_FORWARD"
          break
        elseif #self.pathPoints > 5 then
          table.remove(self.pathPoints, 1)
        end