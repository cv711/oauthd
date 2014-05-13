#################################
# Validate account email + pass #
#################################


"use strict"
define [
	"services/MenuService"
	"services/UserService"
	], () ->
		ValidateCtrl = ($rootScope, $timeout, $scope, $routeParams, MenuService, UserService, $location, $cookieStore) ->
			#MenuService.changed()
			#if UserService.isLogin()
			#	$location.path '/key-manager'
			# console.log "start isValidable"
			UserService.isValidable $routeParams.id, $routeParams.key, ((data) ->
				# console.log "check if validable", data
				$location.path '/404' if not data.data.is_validable and not data.data.is_updated

				if UserService.isLogin() and data.data.is_updated
					mixpanel.track "update mail validate"
					$rootScope.me.profile.mail = $rootScope.me.profile.mail_changed
					$rootScope.me.profile.mail_changed = null
					$rootScope.me.validated = '1'
					$location.path '/account'
				else if data.data.is_validable
					# $location.path '/signin'
					$scope.user =
						id: $routeParams.id
						key: $routeParams.key
						mail: data.data.mail
					UserService.validate $scope.user.id, $scope.user.key, ((data) ->
						mixpanel.track "user validate"
						$rootScope.accessToken = $cookieStore.get 'accessToken'
						UserService.initialize()
					), (error) ->
				else if not data.data.is_validable
					$location.path '/404'
			), (error) ->
				$location.path '/404'
		return [
			"$rootScope",
			"$timeout",
			"$scope",
			"$routeParams",
			"MenuService",
			"UserService",
			"$location",
			"$cookieStore",
			ValidateCtrl
		]