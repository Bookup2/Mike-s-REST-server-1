object WebModule1: TWebModule1
  OnCreate = WebModuleCreate
  Actions = <
    item
      Default = True
      Name = 'DefaultHandler'
      PathInfo = '/'
      OnAction = WebModule1DefaultHandlerAction
    end
    item
      MethodType = mtGet
      Name = 'WebActionItem1'
      PathInfo = '/ChessEngine'
      OnAction = WebModule1WebActionItem1Action
    end>
  Height = 230
  Width = 415
end
