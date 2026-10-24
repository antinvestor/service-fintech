// This is a generated file - do not edit.
//
// Generated from field/v1/field.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'field.pb.dart' as $2;
import 'field.pbjson.dart';

export 'field.pb.dart';

abstract class FieldServiceBase extends $pb.GeneratedService {
  $async.Future<$2.AgentSaveResponse> agentSave(
      $pb.ServerContext ctx, $2.AgentSaveRequest request);
  $async.Future<$2.AgentGetResponse> agentGet(
      $pb.ServerContext ctx, $2.AgentGetRequest request);
  $async.Future<$2.AgentSearchResponse> agentSearch(
      $pb.ServerContext ctx, $2.AgentSearchRequest request);
  $async.Future<$2.AgentHierarchyResponse> agentHierarchy(
      $pb.ServerContext ctx, $2.AgentHierarchyRequest request);
  $async.Future<$2.AgentBranchSaveResponse> agentBranchSave(
      $pb.ServerContext ctx, $2.AgentBranchSaveRequest request);
  $async.Future<$2.AgentBranchDeleteResponse> agentBranchDelete(
      $pb.ServerContext ctx, $2.AgentBranchDeleteRequest request);
  $async.Future<$2.AgentBranchListResponse> agentBranchList(
      $pb.ServerContext ctx, $2.AgentBranchListRequest request);
  $async.Future<$2.ClientSaveResponse> clientSave(
      $pb.ServerContext ctx, $2.ClientSaveRequest request);
  $async.Future<$2.ClientGetResponse> clientGet(
      $pb.ServerContext ctx, $2.ClientGetRequest request);
  $async.Future<$2.ClientSearchResponse> clientSearch(
      $pb.ServerContext ctx, $2.ClientSearchRequest request);
  $async.Future<$2.ClientReassignResponse> clientReassign(
      $pb.ServerContext ctx, $2.ClientReassignRequest request);
  $async.Future<$2.ClientOwnershipTransferResponse> clientOwnershipTransfer(
      $pb.ServerContext ctx, $2.ClientOwnershipTransferRequest request);
  $async.Future<$2.ClientRelationshipSaveResponse> clientRelationshipSave(
      $pb.ServerContext ctx, $2.ClientRelationshipSaveRequest request);
  $async.Future<$2.ClientRelationshipGetResponse> clientRelationshipGet(
      $pb.ServerContext ctx, $2.ClientRelationshipGetRequest request);
  $async.Future<$2.ClientRelationshipSearchResponse> clientRelationshipSearch(
      $pb.ServerContext ctx, $2.ClientRelationshipSearchRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'AgentSave':
        return $2.AgentSaveRequest();
      case 'AgentGet':
        return $2.AgentGetRequest();
      case 'AgentSearch':
        return $2.AgentSearchRequest();
      case 'AgentHierarchy':
        return $2.AgentHierarchyRequest();
      case 'AgentBranchSave':
        return $2.AgentBranchSaveRequest();
      case 'AgentBranchDelete':
        return $2.AgentBranchDeleteRequest();
      case 'AgentBranchList':
        return $2.AgentBranchListRequest();
      case 'ClientSave':
        return $2.ClientSaveRequest();
      case 'ClientGet':
        return $2.ClientGetRequest();
      case 'ClientSearch':
        return $2.ClientSearchRequest();
      case 'ClientReassign':
        return $2.ClientReassignRequest();
      case 'ClientOwnershipTransfer':
        return $2.ClientOwnershipTransferRequest();
      case 'ClientRelationshipSave':
        return $2.ClientRelationshipSaveRequest();
      case 'ClientRelationshipGet':
        return $2.ClientRelationshipGetRequest();
      case 'ClientRelationshipSearch':
        return $2.ClientRelationshipSearchRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'AgentSave':
        return agentSave(ctx, request as $2.AgentSaveRequest);
      case 'AgentGet':
        return agentGet(ctx, request as $2.AgentGetRequest);
      case 'AgentSearch':
        return agentSearch(ctx, request as $2.AgentSearchRequest);
      case 'AgentHierarchy':
        return agentHierarchy(ctx, request as $2.AgentHierarchyRequest);
      case 'AgentBranchSave':
        return agentBranchSave(ctx, request as $2.AgentBranchSaveRequest);
      case 'AgentBranchDelete':
        return agentBranchDelete(ctx, request as $2.AgentBranchDeleteRequest);
      case 'AgentBranchList':
        return agentBranchList(ctx, request as $2.AgentBranchListRequest);
      case 'ClientSave':
        return clientSave(ctx, request as $2.ClientSaveRequest);
      case 'ClientGet':
        return clientGet(ctx, request as $2.ClientGetRequest);
      case 'ClientSearch':
        return clientSearch(ctx, request as $2.ClientSearchRequest);
      case 'ClientReassign':
        return clientReassign(ctx, request as $2.ClientReassignRequest);
      case 'ClientOwnershipTransfer':
        return clientOwnershipTransfer(
            ctx, request as $2.ClientOwnershipTransferRequest);
      case 'ClientRelationshipSave':
        return clientRelationshipSave(
            ctx, request as $2.ClientRelationshipSaveRequest);
      case 'ClientRelationshipGet':
        return clientRelationshipGet(
            ctx, request as $2.ClientRelationshipGetRequest);
      case 'ClientRelationshipSearch':
        return clientRelationshipSearch(
            ctx, request as $2.ClientRelationshipSearchRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => FieldServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => FieldServiceBase$messageJson;
}
