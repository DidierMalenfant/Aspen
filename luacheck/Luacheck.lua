-- Globals provided by Aspen.
--
-- This file can be used by toyboypy (https://toyboxpy.io) to import into a project's luacheck config.
--
-- Just add this to your project's .luacheckrc:
--    require "toyboxes/luacheck" (stds, files)
--
-- and then add 'toyboxes' to your std:
--    std = "lua54+playdate+toyboxes"

return {
    globals = {
        dm = {
            fields = {
                aspen = {
                    fields = {
                        Engine = {
                            fields = {
                                super = {
                                    fields = {
                                        className = {},
                                        init = {}
                                    }
                                },
                                className = {},
                                init = {},
                                createPlayer = {},
                                loadLevel = {},
                                setBackgroundImage = {},
                                setCameraYOffset = {}
                            }
                        },
                        Level= {
                            fields = {
                                super = {
                                    fields = {
                                        className = {},
                                        init = {}
                                    }
                                },
                                className = {},
                                init = {},
                                size = {},
                                setupWallSprites = {},
                                updateCameraPosition = {},
                                update = {},
                                draw = {}
                            }
                        },
                        Player = {
                            fields = {
                                super = {
                                    fields = {
                                        className = {},
                                        init = {}
                                    }
                                },
                                className = {},
                                init = {},
                                State = {
                                    fields = {
                                        idle = {},
                                        walking = {},
                                        jumping = {}
                                    }
                                },
                                stateName = {},
                                setCenter = {},
                                setCollideRect = {},
                                setJumpSound = {},
                                setPlayerMovedCallback = {},
                                setPos = {},
                                moveTo = {},
                                lateralPush = {},
                                goJump = {},
                                goIdle = {},
                                goWalking = {},
                                applyPhysics = {},
                                update = {},
                                idle = {},
                                walking = {},
                                jumping = {}
                            }
                        },
                        PlayerPhysics = {
                            fields = {
                                super = {
                                    fields = {
                                        className = {},
                                        init = {}
                                    }
                                },
                                className = {},
                                init = {}
                            }
                        }
                    }
                }
            }
        }
    }
}
